# Layered Defense Architecture Against Credential Stuffing

**Status:** Design / for team review
**Scope:** Login, registration, and account-recovery paths across web and native app surfaces
**Goal:** Deter a near-human credential-stuffing adversary completely — by making the campaign economically unviable *and* progressively removing the attack surface.

---

## 1. Problem statement

The platform faces an adversary conducting credential stuffing against a B2C surface with the following characteristics:

- Operates from **residential proxies inside the country of operation**.
- Traffic is behaviourally near-identical to legitimate players; **bot management scores most of it "likely human"** and a low bot score can equally be a real user.
- **Request-level fingerprinting is defeated**, including JA4. Tarpits do not work. Rate limiting mitigates volume but attacks still land.
- **MFA not yet implemented** (planned to roll out in a few months).

**Key conclusion:** We have hit the ceiling of *detection*. No per-request signal cleanly separates this adversary from a real player. The strategy therefore shifts away from "is this request a bot" toward two things the adversary cannot disguise:

1. The **validity and value of the credentials** being tested.
2. The **economics** of running the campaign.

Complete deterrence, in practice, means making this platform unprofitable relative to the next target: driving the required attempts-per-successful-takeover *up* while driving the value-per-takeover *down*, until the ROI on residential-proxy spend goes negative.

---

## 2. Strategic model — three layers

The whole design is three layers stacked on top of each other. Each does a different job; none is sufficient alone.

| Layer | Job | Mechanism | Effect on adversary |
|---|---|---|---|
| **A. Detection / economics** | Tax and detect attempts | Risk engine + graduated responses | Raises *cost per attempt* |
| **B. Value destruction** | Devalue what a success is worth | Breach screening at set-time, password history, MFA | Lowers *value per success* |
| **C. Surface elimination** | Remove the attack surface entirely | Passkeys / WebAuthn | Removes enrolled accounts from the target set permanently |

The campaign dies where the cost curve (A) and the value curve (B) cross into negative ROI, while (C) steadily shrinks the population the adversary can even reach.

---

## 3. Layer A — the risk engine

### 3.1 Core principle: one brain, many sensors

**Every control emits a *signal*, not a *verdict*.** No control takes terminal action on its own. Each contributes a value into a single shared risk score computed in the backend; that score alone decides the response.

This is the central architectural rule. The failure mode to avoid is several controls each deciding independently (Cloudflare challenging at the edge, Turnstile firing on its own logic, the device check gating separately) — that produces double-challenges for legitimate users and gaps for the adversary.

> **Client asserts, server judges.** Edge and client components *gather and relay*. The backend *verifies and decides*.

### 3.2 Signals, grouped by fakeability

Weight signals by **what the adversary structurally cannot fake**, not by how technically visible they are. The temptation is to over-weight visible client/environment signals — resist it; that is the category this adversary has already beaten.

Weights below are **illustrative starting points to calibrate**, not final values. They are on an arbitrary additive scale where higher = more suspicious; negative = suppresses suspicion.

#### Per-session signals

| Signal | What it proves | Strength | Illustrative weight | Notes |
|---|---|---|---|---|
| **Client-trust value** (Turnstile on web / attestation on native) | Client is trustworthy for its surface | Strong (native), moderate (web) | valid: −3 · benign-fail: +1 · fail/tampered: +4 | Normalized to one common slot — see §4 |
| **Device token** | This device has authenticated here before | High when present; weak-alone when absent | present-valid: −4 · absent: +1 | Absent is normal for new-device logins; power is combinatorial |
| **Account history** | Novelty vs *this account's* own past (device, ASN, cadence, dormancy, failed-login density) | **Strong — the workhorse** | +1 to +4 depending on deviation | Per-account baseline, not global reputation. Survives the no-geo decision |
| **Leaked-credential flag** (Cloudflare, annotate mode) | The credential is known-compromised | Ambiguous alone, powerful composed | +1 alone · +4 combined with absent token | Also routes to set-time rotation (Layer B) |

#### Cross-session / population signals (rolling window)

| Signal | What it detects | Illustrative effect |
|---|---|---|
| **Fan-out** (distinct usernames per source ASN / /24) | Classic stuffing shape | Global threshold tightening |
| **Spray** (distinct sources per username) | Proxy rotation against one account | Per-account elevation + global tightening |
| **Failure-rate slope** (global) | Campaign spike — most attempts fail by design | Global tightening |
| **New-account velocity per source** | Registration abuse / multi-accounting | Feeds advantage-play controls too |
| **Honeytoken tripwire** | A sourced list is live *right now* | 100% confidence when it fires; global "tighten everything" flag |

#### Client/environment signals (near-zero weight — garnish only)

Behavioural biometrics, headless/automation indicators, canvas/WebGL entropy, timezone-vs-IP, Accept-Language-vs-geo. **Include cheaply, never gate on them.** This adversary already defeats this category; these only catch the *lazy* days of an otherwise-careful campaign.

### 3.3 Design principles for the score

- **Weight by fakeability, not intuitiveness.** Account-history and population signals carry the real weight; client-environment signals near zero.
- **Almost everything is combinatorial.** No single weak signal should cross a threshold alone. "No device token" alone must stay quiet (it challenges every new-phone user). "No token **+** breach hit **+** account-novel ASN" is high-confidence hostile.
- **Watch signal correlation.** Fan-out and spray are two views of one campaign; account-ASN-novelty and impossible-travel overlap. Don't let correlated signals triple-count into a false positive on an unusual-but-legit login.
- **Per-account/per-credential baselines beat global reputation.** The single biggest lever against an in-country residential adversary is asking "is this anomalous *for this account*" rather than "is this source bad in general."

### 3.4 The response ladder (output ← score)

The score picks a rung. MFA is **one response, the heavy end — not a signal**.

| Score band | Response |
|---|---|
| Low (known-good) | **Invisible** — no friction |
| Moderate | **Silent client check** — Turnstile (web) / attestation already covers native |
| Elevated + breach flag | **Set-time password rotation** at next natural opportunity (Layer B) |
| High | **Step-up MFA** |
| Campaign-active (honeytoken/population) | **Global tightening** — all thresholds lowered for the duration, then relaxed |

---

## 4. Web + native convergence

**One platform, two front doors.** There is one auth service, one risk engine, one account store — with two entry *surfaces* (browser, native app). The surface-specific piece lives at the **edge**; the decision lives in the **core**. They never actually meet, because both are reduced to the same signal before any decision happens.

### 4.1 Client-trust sensor, split by surface

- **Web** → Turnstile (browser-native; risk-gated, not flat — see §4.4).
- **Native** → platform attestation: **App Attest / DeviceCheck (iOS)** and **Play Integrity (Android)**.

Each surface runs **only its own sensor**. A web user never touches attestation; a native user never touches Turnstile.

### 4.2 Normalization — the load-bearing step

The two sensors are not natively comparable (Turnstile ≈ pass/fail; attestation = cryptographic verdict with several benign-failure modes). Define, once per sensor, the mapping to a **common client-trust value**:

| Common value | Attestation (native) | Turnstile (web) |
|---|---|---|
| **high** | valid assertion | pass |
| **medium** (elevate, don't block) | benign failure — old OS, service hiccup, rooted-but-legit | unclear |
| **low** | tampered / emulator | fail |

After this mapping, the risk engine has **one input slot** for client trust and is entirely surface-blind. This is what makes "the engine treats them the same" actually true rather than hand-wavy.

### 4.3 Why they don't interfere

- Each surface runs only its sensor — no user gets both or the wrong one.
- Both normalize to one slot — you maintain two thin adapters into one shared path, not two decision paths.
- Blast radius is contained: a risk-engine change affects both surfaces identically and correctly; a Turnstile change touches only web; an attestation change touches only native.
- The core signals underneath (device token, account history, leaked-cred flag, population) are already surface-agnostic — they never branch at all.

### 4.4 Turnstile deployment note

Deploy **risk-gated, not flat.** A flat challenge on every login taxes hundreds of thousands of legitimate requests as much as the attacker's and burns mobile battery/conversion. Gate it on the signals the adversary structurally can't fake (device-token absence, population anomalies). Turnstile raises *attempt cost* linearly with volume — it does nothing to *success value*, so it only deters in combination with Layer B. Standalone, it just moves the adversary to a cheaper solver.

### 4.5 Attestation deployment notes

- **Server-verified.** The client relays the signed assertion; the backend verifies against Apple/Google keys and produces the client-trust value.
- **Benign failures elevate, never hard-block** — old OS versions, rooted-but-legitimate users, certain devices/regions, service hiccups. An out-of-date app is not an attacker.
- **Attests the client, not the credentials.** A genuine app on a genuine device can still be an attacker typing stuffed credentials by hand. Attestation composes with — does not replace — the breach flag, device token, and account-history signals.

---

## 5. Repository mapping

The nested native project maps cleanly onto the edge-vs-core split. The nesting is an advantage, not just "doable."

### Native project (nested)
- iOS attestation **acquisition** (App Attest): request nonce → call OS → relay signed assertion.
- Android attestation **acquisition** (Play Integrity): same.
- **No decision logic.** Gathers and relays only.

### Platform project (parent / shared backend)
- Attestation **verification** → normalizes to client-trust value.
- Turnstile **verification** → normalizes to client-trust value.
- The **risk engine** (client-trust + device token + account history + leaked-cred flag + population signals).
- The **response ladder**.

> **Verification must NOT live in the native project.** If it did, the native surface would make its own trust decision — the exact "two decision-makers" failure the convergence design removes. The native project relays a signature; the parent project decides what it means.

### The nonce contract
The backend issues a one-time nonce, the app attests over it, the backend verifies that same nonce (this is what stops replay of captured assertions). Because the native project is **nested in** the platform repo — same repo, build context, review — this contract lives in one place, avoiding the client/server drift that plagues attestation when mobile code sits in a wholly separate repo with its own release cadence.

### Native-specific caveats
- **Release cadence** is slow and un-rollback-able (app stores). Keep decision logic in the backend so thresholds/mappings can change without an app-store round-trip — a second, independent reason verification belongs in the parent.
- **Version skew:** old app versions live in the wild for a long time. The backend must handle older attestation payloads gracefully → folds into "benign failure = elevate, don't block."
- **Two OS SDKs differ** in shape and failure modes; normalization at the backend is what collapses both into one client-trust value.

---

## 6. Layer B — value destruction

These attack the *worth* of a successful stuff, and fix defects that currently make remediation ineffective.

### 6.1 Password history (fix first — small, high impact)
**Defect:** after a forced reset, users can re-enter their old password, so remediation is theatre — the account stays compromised.
**Fix:** block reuse of the current password on reset at minimum; better, store hashes of the last *N* and compare. This is the difference between a reset that rotates the secret and one that does nothing.

### 6.2 Breach screening at set-time (not login)
The earlier friction from Cloudflare's leaked-credential feature was almost certainly a matter of **where** it ran. Screening at **login** taxes every legitimate player whose old password sits in a corpus, forever.

**Correct approach (per NIST SP 800-63B):** screen when a password is *set* — registration, change, reset — and respond with "choose a different one." A one-time, expected interaction; the continuous login friction disappears. Also **drop** composition rules (symbols/uppercase) and periodic forced rotation — they add friction without security. Keep: minimum length + breach screening at set-time.

This composes with §6.1: breach-screen at set-time and a forced reset now genuinely rotates the user to something not in the corpus.

**Re-enabling Cloudflare's leaked-credential feature is now viable** specifically because it runs in **annotate/log mode** and pairs with the device token (§3.2): a breach hit on a *known device* is almost certainly the legitimate owner reusing a password — suppress the login challenge, route to set-time rotation. A breach hit on an *unknown device* is the genuinely elevated quadrant. The device token rescues the breach feature from its own false-positive problem.

Use a **k-anonymity range API** so full credentials are never transmitted; rate-limit the set-time checks.

### 6.3 Registration verification
**Defect:** no verification on registration → lowers cost of account creation/enumeration (stuffing) *and* opens multi-accounting / bonus abuse (advantage play).
**Fix:** email/phone verification at registration. Given the regulated/gaming context, a verification obligation likely already exists at KYC/withdrawal, so pulling a lightweight check forward is often a smaller lift than it appears. Device fingerprinting / multi-accounting detection serves both advantage-play deterrence and population-level stuffing detection — one investment, two problems.

### 6.4 MFA (adaptive / step-up)
Already planned. Apply on **risk**, not uniformly, to preserve conversion: new device, new ASN, breach-flag match, or sensitive action (email change, payout, password change). Returning users on known devices see nothing. This is the heavy end of the response ladder (§3.4).

---

## 7. Layer C — surface elimination (WebAuthn / passkeys)

Passkeys are **not another signal** — they *remove* the attack surface. With no shared secret, credential stuffing is **impossible against enrolled accounts**. This is the ceiling of the strategy and the closest thing to "deter completely" that is actually achievable.

### 7.1 Feasibility — favourable
- **Web:** WebAuthn is native in all current browsers.
- **Native:** platform authenticators use the **same secure hardware already invoked for attestation** — the conceptually hard native-crypto integration is largely done.
- **Conceptual fit:** a passkey is the hardware-backed cryptographic version of the existing device token — private key never leaves the secure element, server holds only the public key. Relying-party backend work sits next to attestation/Turnstile verification in the platform project (same "server judges" pattern).

### 7.2 Honest B2C constraints
- **Cannot be mandated → shrinks the target set, doesn't replace passwords.** Every enrollment permanently removes an account from the addressable population. Passwords and the whole risk engine stay for the residual.
- **Account recovery is the new battleground.** The adversary can't attack the passkey — they attack the *recovery path*. A passkey rollout is only as strong as its recovery flow; if recovery drops back to a stuffable password with no friction, the attack has moved, not gone. **Design recovery with the same (or greater) rigor as login.** The regulated/KYC context may actually give a *stronger* recovery anchor than a typical B2C platform — potentially making recovery safer than average.
- **Registration-verification ordering:** passkeys bind accounts to hardware (helps against multi-accounting), but unverified registration could let someone enroll passkeys on throwaway accounts. Ship §6.3 compatibly.
- **Regulatory:** confirm interaction with identity-assurance obligations — usually complementary.

### 7.3 Plan jointly with MFA
A passkey login is already phishing-resistant, hardware-backed strong-factor auth. For enrolled users, **a passkey can *be* the MFA** — a biometric tap instead of an OTP, stronger *and* lower-friction. The MFA rollout and passkey rollout should **share one design**, not run as separate tracks; for many users they are the same feature done well.

---

## 8. Decisions already made (and why)

| Decision | Rationale |
|---|---|
| **No further geographic controls** | Login-from-any-device is valid player behaviour and is exactly what the device-token layer handles. Geo buys near-zero separation against an in-country residential adversary while adding real friction. Makes per-account history *more* important (it doesn't punish the traveling player). Keep only a near-free "impossible cross-border hop within one session," optional. |
| **Honeytoken = tripwire only, no fingerprinting** | Attacker-infrastructure attribution is not reachable on the current stack and is low-value against rotating residential proxies. The lightweight version — seed fake credentials, wire a username lookup, treat any hit as a 100%-confidence "campaign live now" boolean → global tightening — costs nothing and needs no new capability. High-confidence when it fires; uninformative when quiet (only fires if the adversary sourced a list we seeded). |
| **PoW via Turnstile, not hand-rolled** | Managed challenge is invisible and in-stack; hand-rolled PoW is easy to get subtly wrong (replay, verification gaps). Adaptive difficulty, risk-gated. |
| **DOM honeypot field kept as hygiene only** | Catches dumb automation, not this adversary (which renders CSS). Near-free, keep it, but not a layer against this actor. |

---

## 9. Suggested sequencing

1. **Password history** — small, stops remediation being theatre.
2. **Breach screening moved to set-time** + re-enable Cloudflare feature in annotate mode — devalues the list *and* removes the old friction.
3. **Registration verification** — closes creation/enumeration and helps advantage play.
4. **Risk engine + device token + account history + population signals** — the shared core; build before leaning on client-trust sensors so there's something reliable to gate on.
5. **Client-trust sensors** — Turnstile (web, risk-gated) + attestation (native), normalized to one slot.
6. **MFA (adaptive)** lands on a much cleaner base — by now the list is worth less, fake-account supply is constrained, and successes don't persist, so MFA removes the residual payoff rather than doing all the work alone.
7. **Passkeys / WebAuthn** — planned jointly with MFA; recovery flow treated as the critical sub-problem. Steadily drains the password population.

---

## 10. Honest limitations

- **Pure defense relocates a determined adversary; it rarely makes them vanish outright.** The realistic win is negative ROI → they move to an easier target.
- **Turnstile taxes attempts, not success value** — deters only in combination with Layer B.
- **Attestation is native-only and attests the client, not the credential or the person.**
- **Client/environment signals are already defeated** — near-zero weight, not load-bearing.
- **Honeytoken is silent when the adversary's list wasn't seeded** — absence of a hit is not absence of attack.
- **Passkey value leaks entirely back out through a careless recovery flow** — recovery is the hard problem, not enrollment.

---

*This document captures the full defense-in-depth design: the detection/economics risk engine (Layer A), value destruction (Layer B), and surface elimination (Layer C), with the web/native convergence mapped to the existing repo structure. Weights and thresholds are illustrative starting points for the team to calibrate against real traffic.*
