### USER
write me Splunk queries for Imperva Advanced Bot Protection.  
  
Write me some use cases with their corresponding queries. They can be either for detecting threats, or for troubleshooting

### ASSISTANT
# Splunk Queries for Imperva Advanced Bot Protection

Here's a comprehensive set of use cases with corresponding Splunk queries, organized by category.

---

## 🔴 Threat Detection Use Cases

### 1. **Top Bot Attack Sources by IP**
*Identify the most aggressive bot sources hitting your environment.*
```spl
index=imperva sourcetype="imperva:abp"
| search bot_classification!="benign" action="block"
| stats count AS attack_count BY src_ip, bot_classification, country
| sort -attack_count
| head 20
```

### 2. **Credential Stuffing / Account Takeover Attempts**
*Detect high-volume login attempts from bot sources targeting authentication endpoints.*
```spl
index=imperva sourcetype="imperva:abp"
| search uri_path IN ("/login", "/signin", "/auth", "/api/login", "/account/login")
  bot_classification="bad_bot" OR bot_classification="malicious"
| stats count AS login_attempts, dc(src_ip) AS unique_ips BY uri_path, action
| where login_attempts > 100
| sort -login_attempts
```

### 3. **CAPTCHA Challenge Failures (Likely Automated Bots)**
*Bots that are failing CAPTCHA challenges are strong indicators of automation.*
```spl
index=imperva sourcetype="imperva:abp"
| search challenge_type="captcha" challenge_result="failed"
| stats count AS failed_challenges BY src_ip, user_agent, country
| where failed_challenges > 10
| sort -failed_challenges
```

### 4. **Spike in Bot Traffic (Anomaly Detection)**
*Detect unusual surges in bot-classified traffic that may indicate an attack campaign.*
```spl
index=imperva sourcetype="imperva:abp"
| search bot_classification="bad_bot" OR bot_classification="malicious"
| timechart span=1h count AS bot_hits
| eventstats avg(bot_hits) AS avg_hits, stdev(bot_hits) AS stdev_hits
| eval threshold = avg_hits + (3 * stdev_hits)
| where bot_hits > threshold
| table _time, bot_hits, avg_hits, threshold
```

### 5. **Web Scraping Detection**
*Identify bots aggressively scraping content pages.*
```spl
index=imperva sourcetype="imperva:abp"
| search bot_classification="bad_bot" action IN ("block", "monitor")
  http_method="GET"
| stats count AS requests, dc(uri_path) AS unique_pages, values(user_agent) AS agents BY src_ip
| where unique_pages > 50 AND requests > 500
| sort -requests
```

### 6. **Blocked Bot Activity by Attack Type**
*Understand the distribution of bot attack types being blocked.*
```spl
index=imperva sourcetype="imperva:abp"
| search action="block"
| stats count BY bot_violation_type, bot_classification
| sort -count
| rename bot_violation_type AS "Attack Type", bot_classification AS "Bot Class", count AS "Blocked Events"
```

### 7. **Suspicious User-Agent Strings**
*Find user-agents commonly associated with bot frameworks (Selenium, Puppeteer, etc.).*
```spl
index=imperva sourcetype="imperva:abp"
| search user_agent="*headless*" OR user_agent="*phantomjs*" OR user_agent="*selenium*"
  OR user_agent="*puppeteer*" OR user_agent="*python-requests*" OR user_agent="*scrapy*"
  OR user_agent="*curl*" OR user_agent="*wget*"
| stats count BY user_agent, src_ip, action, bot_classification
| sort -count
```

### 8. **API Abuse – High-Frequency Requests to API Endpoints**
*Detect bots hammering API endpoints.*
```spl
index=imperva sourcetype="imperva:abp"
| search uri_path="/api/*" bot_classification!="benign"
| bin _time span=5m
| stats count AS api_requests BY src_ip, uri_path, _time
| where api_requests > 200
| sort -api_requests
```

### 9. **Geographic Anomalies – Bot Traffic from Unusual Regions**
*Flag bot traffic from countries you don't typically serve.*
```spl
index=imperva sourcetype="imperva:abp"
| search bot_classification="bad_bot" OR bot_classification="malicious"
| stats count AS bot_requests BY country, src_ip
| where NOT country IN ("US", "GB", "DE", "FR", "MT")
| sort -bot_requests
| head 30
```

### 10. **Session Hijacking / Cookie Replay Detection**
*Detect multiple IPs using the same session token — indicates session hijacking.*
```spl
index=imperva sourcetype="imperva:abp"
| search session_id!=""
| stats dc(src_ip) AS ip_count, values(src_ip) AS source_ips BY session_id
| where ip_count > 1
| sort -ip_count
```

---

## 🔧 Troubleshooting Use Cases

### 11. **False Positive Analysis – Legitimate Traffic Being Blocked**
*Identify potentially legitimate users being incorrectly blocked.*
```spl
index=imperva sourcetype="imperva:abp"
| search action="block" bot_classification="good_bot" OR bot_classification="benign"
| stats count BY src_ip, user_agent, uri_path, bot_classification, bot_violation_type
| sort -count
```

### 12. **Policy Action Distribution Overview**
*Understand how ABP policies are being enforced (block, captcha, monitor, allow).*
```spl
index=imperva sourcetype="imperva:abp"
| stats count BY action, bot_classification
| sort action, -count
| rename action AS "Policy Action", bot_classification AS "Classification", count AS "Event Count"
```

### 13. **Challenge Pass Rate (CAPTCHA / JS Challenge)**
*Monitor how often challenges are passed vs. failed — low pass rates may indicate over-aggressive policies.*
```spl
index=imperva sourcetype="imperva:abp"
| search challenge_type IN ("captcha", "js_challenge")
| stats count(eval(challenge_result="passed")) AS passed,
        count(eval(challenge_result="failed")) AS failed BY challenge_type
| eval pass_rate = round((passed / (passed + failed)) * 100, 2)
| table challenge_type, passed, failed, pass_rate
```

### 14. **ABP Log Ingestion Health Check**
*Ensure logs are flowing into Splunk consistently (detect ingestion gaps).*
```spl
index=imperva sourcetype="imperva:abp"
| timechart span=15m count AS event_count
| where event_count < 10
| eval alert_msg = "Possible log ingestion gap detected at " . strftime(_time, "%Y-%m-%d %H:%M")
| table _time, event_count, alert_msg
```

### 15. **Latency Impact from ABP Mitigation Actions**
*Check if ABP actions are introducing latency on protected sites.*
```spl
index=imperva sourcetype="imperva:abp"
| search response_time!=""
| eval action_group = case(
    action="block", "Blocked",
    action="captcha", "Challenged",
    action="monitor", "Monitored",
    1=1, "Other")
| stats avg(response_time) AS avg_latency_ms, p95(response_time) AS p95_latency_ms BY action_group
| eval avg_latency_ms = round(avg_latency_ms, 2)
| eval p95_latency_ms = round(p95_latency_ms, 2)
| table action_group, avg_latency_ms, p95_latency_ms
```

### 16. **Specific Site/Application Troubleshooting**
*Drill into ABP events for a specific protected site.*
```spl
index=imperva sourcetype="imperva:abp"
| search site_name="www.example.com"
| stats count BY action, bot_classification, bot_violation_type
| sort -count
```

### 17. **Client Fingerprint Collision Check**
*Identify if multiple distinct users share the same device fingerprint (may indicate spoofing).*
```spl
index=imperva sourcetype="imperva:abp"
| search device_fingerprint!=""
| stats dc(src_ip) AS unique_ips, dc(session_id) AS unique_sessions BY device_fingerprint
| where unique_ips > 5
| sort -unique_ips
```

### 18. **Monitor Mode Audit – What WOULD Be Blocked**
*Review events in monitor mode to assess impact before switching to block.*
```spl
index=imperva sourcetype="imperva:abp"
| search action="monitor" bot_classification IN ("bad_bot", "malicious")
| stats count AS would_be_blocked BY uri_path, bot_violation_type, src_ip
| sort -would_be_blocked
| head 50
```

---

## 📊 Bonus: Executive Dashboard Query

### 19. **Daily Bot Protection Summary**
```spl
index=imperva sourcetype="imperva:abp"
| stats count(eval(action="block")) AS blocked,
        count(eval(action="captcha")) AS challenged,
        count(eval(action="monitor")) AS monitored,
        count(eval(action="allow")) AS allowed,
        dc(src_ip) AS unique_bot_ips,
        count AS total_events
| eval block_rate = round((blocked / total_events) * 100, 2) . "%"
| table total_events, blocked, challenged, monitored, allowed, unique_bot_ips, block_rate
```

---

## ⚠️ Important Notes

| Consideration | Detail |
|---|---|
| **Field Names** | Actual field names depend on your Imperva log format (CEF, LEEF, JSON, Syslog). Adjust fields like `bot_classification`, `bot_violation_type`, `action`, etc. to match your environment. |
| **Index & Sourcetype** | Replace `index=imperva` and `sourcetype="imperva:abp"` with your actual index and sourcetype values. |
| **Imperva SIEM Integration** | Ensure the Imperva Cloud WAF → SIEM log integration is configured (via Log Setup in Imperva Console) and that ABP-specific fields are being forwarded. |
| **Tuning Thresholds** | Numeric thresholds (e.g., `> 100`, `> 500`) should be tuned based on your traffic baseline. |

Would you like me to expand on any of these, create alert-ready versions with `| sendalert`, or build a specific dashboard XML?

### USER
the index is “imperva-bot-mitigation”. Consult Imperva documentation on which fields and log sources to use for Splunk queries.

### ASSISTANT
# Imperva Advanced Bot Protection (ABP) SIEM Log Integration Overview

**Imperva Advanced Bot Protection (ABP)** provides detailed security event logs for automated threats (malicious bots) targeting web applications, mobile apps, and APIs (docs.hunters.ai). These **bot mitigation event** logs can be exported from the Imperva Cloud WAF platform to a SIEM (like Splunk) using Imperva’s Near **Real-Time SIEM Logging** feature (docs-cybersec.thalesgroup.com) (docs-cybersec.thalesgroup.com). Key aspects of the integration – including log **formats, sourcetypes, field names, and available event fields** – are summarized below, based on official Imperva documentation.

### Supported Log Formats for ABP SIEM Logs

Imperva’s SIEM log integration supports multiple output formats for its Cloud WAF and security services. The **Advanced Bot Protection logs** can be delivered in **Common Event Format (CEF)**, **Log Event Extended Format (LEEF)**, **W3C extended log format**, or as **structured JSON** (Newline-Delimited JSON) files (docs-cybersec.thalesgroup.com) (docs.cloud.google.com). In the Imperva management console, when configuring the SIEM log **connection for ABP**, you will typically select the **“JSON (structured)” format** for the Advanced Bot Protection service (docs.cloud.google.com). This structured JSON format is designed to provide key–value fields (including nested objects for certain data) for easier parsing in modern SIEMs. However, legacy integration methods (such as older SFTP or syslog feeds) may use CEF, LEEF, or W3C formats, which represent the same information with different field naming conventions (docs-cybersec.thalesgroup.com) (docs-cybersec.thalesgroup.com). It’s important to **consistently use one format** for integration to simplify parsing and field extraction within Splunk.

### Splunk Sourcetype Conventions

When ingesting Imperva ABP logs into Splunk, it’s recommended to assign a distinct **sourcetype** that reflects the format. For example, CEF logs from Imperva Cloud WAF/ABP are often tagged with a sourcetype like **`imperva:cef`**, a convention used by Imperva’s integration tools and community add-ons (docs.hunters.ai). If using LEEF format, a similar convention (e.g., `imperva:leef`) can be applied. For W3C-style logs (text-based field per line), you might use a sourcetype like `imperva:w3c`. In the case of **structured JSON** delivered via the Splunk HTTP Event Collector (HEC) or S3, you can use a custom sourcetype such as **`imperva:abp:json`** (or any name of your choice) and configure Splunk to treat the JSON payload as the event data (docs-cybersec.thalesgroup.com) (docs-cybersec.thalesgroup.com). This typically involves adding a **transform rule** (as described in Imperva’s documentation) so that the JSON is extracted properly into fields in Splunk instead of being indexed as a raw string (docs-cybersec.thalesgroup.com). Using clear sourcetype names helps ensure the correct field extractions (via Splunk’s Add-on or custom **props/transforms** configurations) are applied for each format.

### Key Field Names and Event Schema for Bot Mitigation Events

**Imperva ABP security events** include all the standard Cloud WAF access log fields *plus* additional fields specific to bot detection. The official schema defines each field and its name in different formats (CEF, LEEF, W3C) (docs-cybersec.thalesgroup.com) (docs-cybersec.thalesgroup.com). Below are important fields available in **ABP SIEM logs** (using the field names as documented by Imperva):

- **Account/Site Identification**: Each event includes the account and site identifiers for the protected asset.
 - **Account ID** – appears as `suid` in CEF/LEEF (W3C: `s-suid`), the numerical ID of the Imperva account owner (docs-cybersec.thalesgroup.com).
 - **Account Name** – `Customer` (CEF/LEEF) or `s-accountname` (W3C), the name of the account (organization) (docs-cybersec.thalesgroup.com).
 - **Site ID** – `siteid` (CEF/LEEF) or `s-siteid` (W3C), the numeric identifier for the protected site/application (docs.logrhythm.com).
 - **Site Name** – `sourceServiceName` (CEF/LEEF) or `s-computername` (W3C), the human-readable site name or domain (docs.logrhythm.com).
 - **Site Tag/Reference** – `siteTag` (CEF/LEEF) or `s-sitetag` (W3C), a custom reference ID or tag for the site (if defined) (docs-cybersec.thalesgroup.com) (docs-cybersec.thalesgroup.com).

- **Client Details**: Information about the client making the request.
 - **Client IP** – `src` (CEF/LEEF) or `c-ip` (W3C), the source IP address of the request (the actual client’s IP, taking into account X-Forwarded-For if present) (docs-cybersec.thalesgroup.com).
 - **Client Port** – `cpt` (CEF) or `srcPort` (LEEF) or `c-port` (W3C), the source port used by the client (docs-cybersec.thalesgroup.com).
 - **X-Forwarded-For** – `xff` (CEF/LEEF) or `s-xff` (W3C), the X-Forwarded-For header value (if present), showing the original client IP if the immediate `src` was a proxy or CDN (docs-cybersec.thalesgroup.com).
 - **Client Geographic Info** – `ccode` (CEF; country code) and `cicode` (city name or code) correspond to `cs-countrycode` and `cs-cicode` in W3C logs (docs-cybersec.thalesgroup.com) (docs-cybersec.thalesgroup.com). Latitude and longitude are provided in CEF/LEEF as `cs7` and `cs8` with labels “latitude” and “longitude” respectively (docs-cybersec.thalesgroup.com) (in W3C: `cs-lat` and `cs-long`).
 - **Client Device/Browser** – `requestClientApplication` (CEF/LEEF; in W3C this is the `cs (User-Agent)` field), which records the full User-Agent string of the client (docs-cybersec.thalesgroup.com). Imperva also provides a parsed **Client Application Name** as `cs6` with label `clapp` (for “client application”) in CEF/LEEF (W3C: `cs-clapp`) – for example, “Firefox”, “Chrome”, “Python-urllib”, etc. (docs-cybersec.thalesgroup.com) (docs-cybersec.thalesgroup.com). The **Browser Type** (rendered vs. headless) is given as `dproc` (CEF/LEEF) or `cs-browsertype` (W3C) (docs-cybersec.thalesgroup.com) – e.g., `Browser` for standard web browsers or other values indicating non-browser automation.
 - **Client Capability Indicators** – these fields help identify non-human clients by checking support for browser features (community.imperva.com). They appear as key–value pairs in CEF/LEEF with *custom string (cs)* fields (and similarly in W3C as indicated in the `#Fields` header (docs-cybersec.thalesgroup.com)):
 - `cs1Label=Cap Support` – value `cs1` is “**Captcha Support**”, indicating if the client supports CAPTCHA (e.g., `true`, `false`, or `NOT_SUPPORTED`) (docs-cybersec.thalesgroup.com) (docs-cybersec.thalesgroup.com).
 - `cs2Label=Javascript Support` – value `cs2` indicates **JavaScript support** (true/false) (docs-cybersec.thalesgroup.com).
 - `cs3Label=CO Support` – value `cs3` indicates **Cookie support** (true/false) (docs-cybersec.thalesgroup.com).
 - `cs4Label=VID` – value `cs4` is the **Visitor ID** (a unique identifier for the client, often derived from a tracking cookie) (docs.hunters.ai).
 - `cs5Label=clappsig` – value `cs5` is the **Client Application Signature**, a hash or signature of the client’s characteristics (used internally by Imperva to fingerprint the client) (docs.hunters.ai).
 - (In the structured JSON format, these may appear as fields within an `imperva.abp` object or as top-level boolean fields for capabilities. For example, the presence of `"client": {...}` and nested `user-agent` details, as well as an ABP-specific section like `"imperva.abp"` with detection info, is expected (docs.hunters.ai).)

- **Request Details**: Standard HTTP request/response information.
 - **URL Path** – `request` (CEF) or `url` (LEEF) or `cs-uri` (W3C), the requested URL path (often including domain in CEF/LEEF) (docs-cybersec.thalesgroup.com).
 - **HTTP Method** – `requestMethod` (CEF/LEEF) or `cs-method` (W3C), e.g., GET, POST, etc. (docs-cybersec.thalesgroup.com).
 - **Query String** – `qstr` (CEF; stands for *query string*) or `cs-uri-query` (W3C), the URL query parameters of the request (URL-decoded in CEF/LEEF) (docs.logrhythm.com).
 - **POST Body** – `postbody` (CEF; may appear in JSON/W3C as `cs-postbody`) containing the POST request body data (if logging of request payloads is enabled) (docs.logrhythm.com).
 - **HTTP Status** – `cn1` (CEF) or `sc-status` (W3C), the HTTP response status code returned to the client (docs-cybersec.thalesgroup.com).
 - **Referrer** – `ref` (CEF/LEEF) or `cs(Referrer)` (W3C), the referring page URL (if any) (docs-cybersec.thalesgroup.com).
 - **Response Size** – `in` (CEF/LEEF) or `cs-bytes` (W3C), the size of the response body in bytes (docs-cybersec.thalesgroup.com).
 - **Timestamps** – `start` (CEF/LEEF) or `cs-start` (W3C) for the request start time, and `end` (CEF/LEEF) or `cs-end` (W3C) for the response end time, both in UNIX epoch (ms) UTC (docs-cybersec.thalesgroup.com).
 - **Protocol Details** – `app` (CEF; e.g., HTTP/HTTPS) and `proto`/`protoVer` (LEEF) or `cs-version`/`cs-protver` (W3C) indicating the protocol and version (including TLS version/cipher if applicable) (docs-cybersec.thalesgroup.com).

- **Attack/Mitigation Details**: Fields present for **security events** (bot detections).
 - **Attack Name/Category** – In CEF/LEEF, the *header portion* of the event includes the attack type name and an internal code. For ABP events, this is typically labeled as “Bad Bot” (for **Advanced Bot Protection**) with internal code **14** (docs-cybersec.thalesgroup.com). In the structured JSON, the `event.code` may be `"BOT_DETECTED"` and `event.category` = “web” with `event.dataset` = “AdvancedBotProtection” (docs.hunters.ai).
 - **Imperva Attack ID** – `filePermission` (CEF/LEEF) or `cs-attackid` (W3C), a numeric ID for the specific security **violation instance** (sometimes called *attack ID*) (docs-cybersec.thalesgroup.com).
 - **Attack Type** – `fileType` (CEF/LEEF) or `cs-attacktype` (W3C), indicating the type of attack or security incident. In ABP cases this likely shows “Bad Bot” or similar, identifying a bot mitigation event (docs-cybersec.thalesgroup.com).
 - **Action (Mitigation Outcome)** – `act` (CEF; action) or `sc-action` (W3C) and `cat` (LEEF). This represents what action Imperva took for the request (docs-cybersec.thalesgroup.com) – e.g. **REQ_BLOCKED** (blocked the request), **REQ_CHALLENGE** (issued a challenge like CAPTCHA), or **REQ_PASSED** (allowed the request to proceed). *(Note: As of Dec 20, 2025, Imperva no longer includes purely “allowed” bot traffic in the ABP SIEM feed, focusing only on blocked or challenged/suspicious events (community.imperva.com).)*
 - **Rule Name / Policy** – `cs9` with `cs9Label=Rule name` (CEF/LEEF) or `s-ruleName` (W3C) provides the *name of the bot mitigation rule or policy* that triggered the action (docs.logrhythm.com) (docs-cybersec.thalesgroup.com). For example, this might contain values like “Bad Bot”, “Blocked IP (ACL)”, or custom policy/tag names. Multiple values can appear (comma-separated) if more than one rule or tag was applied (docs-cybersec.thalesgroup.com).
 - **Rule Details / Info** – `cs10`/`cs11` fields may contain **additional structured info** about the trigger. For ABP, Imperva may include JSON data about the detection method or rule version (for example, an internal rule set name, sometimes referred to as “Apollo” rules in ABP) in a field like `cs10` or within the `imperva.abp` JSON object (docs.hunters.ai). Other security services (like API Security) use `cs11` (`cs-ruleInfo`) for detailed violation information (docs-cybersec.thalesgroup.com). These fields provide context on *why* the request was flagged, such as machine learning model IDs, anomaly scores, or policy identifiers.

With these field names and their meanings established, we can now explore various **Splunk queries** to address common *Threat Detection* and *Troubleshooting* use cases for Imperva ABP (bot mitigation) events. Each use case below is presented with a brief description and an example **Splunk Processing Language (SPL)** query. All queries assume that your Imperva ABP events have been indexed in a dedicated index (e.g., **`index="imperva-bot-mitigation"`**) and that field extractions or JSON parsing are properly configured so the documented field names (like `src`, `cs1`, `requestClientApplication`, etc.) are available for searching. Adjust time ranges and thresholds as needed for your environment.

## Threat Detection Use Cases

Below are several use cases focusing on detecting malicious **bot activity** and suspicious patterns using ABP log fields. These queries help security analysts identify potential threats and trends in automated traffic, leveraging the **exact field names** from Imperva’s ABP log schema.

### Use Case 1: Detect Sudden Spikes in Bot Attack Volume
**Goal:** Identify an unusual surge in the volume of bot mitigation events, which could indicate a large-scale bot attack (e.g., a scraping campaign or credential stuffing bot swarm). Since the ABP SIEM feed includes primarily **blocked or challenged bot requests** (community.imperva.com), a sudden increase in event count likely signifies malicious bot activity targeting your applications. The query below creates a time series count of events and highlights any 1-hour interval where the count exceeds a baseline (three times the average in the last 24 hours, in this example).

**SPL Query:**
```splunk
index="imperva-bot-mitigation" earliest=-24h 
| bin span=1h _time 
| stats count as hourly_bots by _time 
| eventstats avg(hourly_bots) as avg_bots stdev(hourly_bots) as sd_bots 
| where hourly_bots > avg_bots + (3 * sd_bots) 
| sort _time
```

### Use Case 2: Top Source IPs with Frequent Bot Blocks
**Goal:** Identify the IP addresses that are generating the most **blocked bot requests**. This helps pinpoint the primary malicious actors (or bot operators) attacking your site. Often, a small number of IPs (or subnets) may be responsible for a large share of bot traffic. The query below filters for blocked requests and returns the top 10 source IPs along with their geographic country code, sorted by event count.

**SPL Query:**
```splunk
index="imperva-bot-mitigation" act=REQ_BLOCKED* 
| stats count AS bot_event_count by src ccode 
| sort - bot_event_count 
| head 10
```

### Use Case 3: Identify Most Targeted URLs by Bots
**Goal:** Determine which URLs or pages on your site are most frequently targeted by malicious bots. This insight can highlight which content (e.g., product pages, login endpoints, APIs) bots are attempting to scrape or attack. The query below finds the top 10 requested URLs (`request` field) among all bot mitigation events, sorted by the number of occurrences.

**SPL Query:**
```splunk
index="imperva-bot-mitigation" act=REQ_BLOCKED* 
| stats count AS bot_request_count by request 
| sort - bot_request_count 
| head 10
```

### Use Case 4: Geographic Distribution of Bot Attacks
**Goal:** Understand the geographic source of blocked bot traffic. Some bot attacks originate disproportionately from certain countries or regions (for example, large volumes of malicious bot traffic might come from data center hosting regions). The query below tallies bot mitigation events by the client’s country (using the two-letter country code in the `ccode` field) to show the top source countries.

**SPL Query:**
```splunk
index="imperva-bot-mitigation" act=REQ_BLOCKED* 
| stats count AS bot_events by ccode 
| sort - bot_events 
| head 5
```

### Use Case 5: Distinguish Basic vs. Advanced Bots (Capability Checks)
**Goal:** Classify bot events based on the sophistication of the bot, by leveraging fields that indicate client capabilities. **Basic bots** often do not support JavaScript or cookies, whereas **advanced bots** may simulate full browser behavior (supporting JS, cookies, etc.) (community.imperva.com). The query below uses the `cs2` (JavaScript support) and `cs3` (Cookie support) fields to categorize each blocked bot request as “Basic Bot” (if either JS or cookies are not supported) versus “Advanced Bot” (if both are supported). This can help track how many sophisticated bots you are encountering.

**SPL Query:**
```splunk
index="imperva-bot-mitigation" act=REQ_BLOCKED* 
| eval BotType = case(cs2=="false" OR cs3=="false", "Basic Bot", cs2=="true" AND cs3=="true", "Advanced Bot", 1==1, "Unknown") 
| stats count by BotType
```

### Use Case 6: Detect Advanced Bots Impersonating Browsers
**Goal:** Find bot incidents where the client was identified as a **standard browser** (`dproc="Browser"`) yet the request was blocked as a bad bot. This can reveal either very sophisticated bots (that mimic real browsers and pass JS/Cookie challenges) or potential false positives where real users were erroneously flagged. The query below searches for blocked requests that Imperva classified as coming from a normal browser and lists the user-agent (`requestClientApplication`) of those events. This helps you review what user agents are involved in “Browser” clients that were still blocked by ABP.

**SPL Query:**
```splunk
index="imperva-bot-mitigation" act=REQ_BLOCKED* dproc="Browser" 
| stats count AS blocked_requests by requestClientApplication 
| sort - blocked_requests
```

### Use Case 7: Detect Malicious Bot Activity on API Endpoints
**Goal:** Identify bot attacks targeting your **API endpoints**. Bots often target API URLs (which frequently contain “`/api/`”) to scrape data or abuse services. The query below filters ABP events for URLs containing “/api/” and shows the top such endpoints under attack, along with the HTTP method used. This helps you see which API calls are being targeted by bots.

**SPL Query:**
```splunk
index="imperva-bot-mitigation" act=* request="*/api/*" 
| stats count AS event_count by requestMethod request 
| sort - event_count 
| head 10
```

### Use Case 8: Breakdown of Bot Mitigation Events by Policy/Rule
**Goal:** Analyze which **bot mitigation rules or policies** are firing most often. Imperva ABP allows custom policies/tags and multiple detection techniques; the logs include a “Rule name” field (`cs9` in CEF/LEEF, or `s-ruleName` in W3C) that indicates the name of the bot rule or tag that triggered the action (docs-cybersec.thalesgroup.com). The query below aggregates events by this field to show the count of events per rule name. This can help identify which bot detection categories (e.g., “Bad Bot”, specific bot signatures, or custom **Bot Mitigation** tags) are most active, informing tuning decisions.

**SPL Query:**
```splunk
index="imperva-bot-mitigation" 
| stats count AS events_by_rule by cs9 
| sort - events_by_rule
```

*Interpretation:* In the results of the above query, the `cs9` values might include generic categories (like *“Bad Bot”* or *“Suspicious Bot”*), specific rule names (e.g., *“Blocked IP (ACL)”* or custom policy names), and even multiple comma-separated entries if more than one tag/rule was applied to the same request (docs-cybersec.thalesgroup.com). Security teams can investigate top entries to see what types of bot behaviors are being most frequently detected.

## Troubleshooting Use Cases

In addition to threat detection, it’s important to monitor the **health and accuracy of the ABP log integration** itself. The following use cases provide Splunk queries to help verify that the integration is functioning correctly, all expected fields are present, and to diagnose potential issues (such as missing data or false positives). These queries use the documented field names from the ABP logs to ensure accuracy in checking the ingestion.

### Use Case 9: Verify ABP Log Ingestion and Freshness
**Goal:** Ensure that ABP events are continuously arriving in Splunk and identify if any site’s logs are delayed or missing. The query below shows the most recent event time (`_time`) for each site (`sourceServiceName`) in the ABP log index. Use this to confirm that each protected site is sending data and to detect if any site’s feed has stopped (showing an unexpectedly old timestamp).

**SPL Query:**
```splunk
index="imperva-bot-mitigation" 
| stats latest(_time) AS last_event_time by sourceServiceName 
| convert ctime(last_event_time) AS last_event_time
```

### Use Case 10: Detect Duplicate Events (Potential Retransmission)
**Goal:** Identify any **duplicate events** in the ABP logs, which can occur if the Imperva SIEM integration retransmits a log file (for example, due to a network timeout or error, the same events might be sent twice) (docs-cybersec.thalesgroup.com). Each ABP request has a unique **request identifier** (`deviceExternalId` in CEF/LEEF, or `event.id` in JSON) (docs-cybersec.thalesgroup.com) (docs.hunters.ai). The query below checks for any duplicates by counting events with the same `deviceExternalId`. If any identifier shows a count greater than 1, those requests were logged multiple times, indicating a potential ingestion duplication issue.

**SPL Query:**
```splunk
index="imperva-bot-mitigation" 
| stats count AS event_count by deviceExternalId 
| where event_count > 1
```

### Use Case 11: Validate Presence of Bot Detection Fields
**Goal:** Confirm that key ABP-specific fields (e.g., `cs1`/`cs2`/`cs3` for CAPTCHA/JS/Cookie support, `cs4` for visitor ID, etc.) are present in the ingested events. If these fields are missing, it could indicate a parsing issue or that the SIEM integration is not configured for structured JSON (or that the account’s plan doesn’t include those fields) (docs-cybersec.thalesgroup.com). The following query counts how many events have values for certain fields versus the total events. Ideally, the count for each field should match the total number of events (meaning the field was extracted in all events). If you see zeros or missing fields, you may need to adjust your parsing configuration or check if those fields are enabled in your Imperva logs.

**SPL Query:**
```splunk
index="imperva-bot-mitigation"
| eval has_CAPTCHA=if(isnotnull(cs1),1,0), has_JS=if(isnotnull(cs2),1,0), has_Cookie=if(isnotnull(cs3),1,0) 
| stats sum(has_CAPTCHA) AS events_with_Captcha_Field, sum(has_JS) AS events_with_JS_Field, sum(has_Cookie) AS events_with_Cookie_Field, count AS total_events
```

### Use Case 12: Check Sourcetype Consistency
**Goal:** Verify that all ABP log events are tagged with the expected Splunk **sourcetype** (to ensure uniform parsing). If multiple sourcetypes appear in the index for the same data, it could lead to inconsistent field extractions. The query below simply displays the count of events per sourcetype in the `imperva-bot-mitigation` index. In a correct setup you should see a single sourcetype (for example, all events tagged as `imperva:cef` or your chosen JSON sourcetype). If more than one sourcetype appears, you may need to unify your data inputs or adjust configuration.

**SPL Query:**
```splunk
index="imperva-bot-mitigation" 
| stats count AS event_count by sourcetype
```

### Use Case 13: Confirm Action Distribution (Blocked vs Challenged)
**Goal:** Confirm that the **actions** recorded in ABP events align with expectations – specifically, after December 20, 2025, Imperva **stopped including “allowed” bot traffic** in SIEM logs (community.imperva.com). This means virtually all ABP events should be *blocked* or *challenged/suspicious* actions, not purely allowed requests. The query below shows a breakdown of event counts by the `act` (action) field. If you see `REQ_PASSED` (or similar **allowed** indicators) appearing in your ABP index, it may indicate an outdated configuration or an unexpected logging of non-actionable events.

**SPL Query:**
```splunk
index="imperva-bot-mitigation" 
| stats count AS events by act
```

### Use Case 14: Identify False Positives – Known Good Bots Flagged
**Goal:** Ensure that **known good bots** (such as search engine crawlers or uptime monitors) are not being inadvertently blocked by ABP. Imperva’s ABP usually differentiates *“good” bots (like Googlebot/Bingbot)* from malicious bots, but misconfigurations or aggressive policies could result in legitimate bots being blocked. The query below searches for any blocked bot events where the user agent or client application name matches common search engine bots (e.g., “Googlebot”). Finding such events suggests that a legitimate bot was flagged, which might require adding it to an allowlist or adjusting your bot policy.

**SPL Query:**
```splunk
index="imperva-bot-mitigation" act=REQ_BLOCKED* requestClientApplication="*Googlebot*"
```

*Tip:* You can modify the above search with other known bot identifiers (e.g., Bingbot, Yahoo! Slurp, etc.) in the `requestClientApplication` filter. If the `clapp` field (Client App) is being used, you could also search `cs6="Googlebot"` or similar, depending on how Imperva labels known bots in the logs.

### Use Case 15: Filter Events by Custom Bot Mitigation Tag or Policy
**Goal:** If you have configured **custom bot mitigation rules or tags** in ABP, you may want to retrieve all events related to a specific policy or tag for analysis. The ABP log’s rule name field (`cs9`/`Rule name`) typically contains the policy name or tag that was applied to the request (docs-cybersec.thalesgroup.com). The query below filters events to those that contain a particular policy name or tag (replace “YourCustomTag” with the actual tag or rule name you’re interested in). This helps validate that your custom bot policies are functioning and allows you to review all incidents associated with them.

**SPL Query:**
```splunk
index="imperva-bot-mitigation" cs9="*YourCustomTag*"
```

*Note:* If your **sourcetype is JSON-structured**, you might need to adjust the query to use the JSON field name for the rule/tag. For example, in W3C the field is `s-ruleName` (docs-cybersec.thalesgroup.com). Ensure you use the field name corresponding to your log format in the search.

## Notes and Caveats

| **Consideration** | **Details** |
|-------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Field Name Variations** | Imperva uses different field keys for the same data depending on log format. For example, the client IP appears as **`src`** in CEF/LEEF, but as **`c-ip`** in W3C format (docs-cybersec.thalesgroup.com). The site name is `sourceServiceName` in CEF/LEEF vs. `s-computername` in W3C (docs.logrhythm.com). In JSON (the default for ABP), fields are nested (e.g. client IP is **`client.ip`** and country code is **`client.geo.country_iso_code`**) (docs.hunters.ai). Ensure your Splunk extractions (or `spath` in queries) handle these variations. |
| **Integration Prerequisites** | The ABP SIEM feed is available to Imperva Cloud WAF customers with the Advanced Bot Protection add-on. You must configure a **SIEM Logs** connection in the Imperva portal and enable *Advanced Bot Protection* log types for your chosen destination (docs.cloud.google.com). If using Splunk HEC or other network destinations, make sure to **allowlist Imperva’s logging IP addresses** so that the data can reach your environment (docs-cybersec.thalesgroup.com) (docs-cybersec.thalesgroup.com). For HEC (structured JSON) integrations, follow Imperva’s guidance to apply the JSON extraction transform on the assigned sourcetype to properly parse nested fields (docs-cybersec.thalesgroup.com). |
| **Tuning Recommendations** | Use the above queries as starting points and adjust thresholds to fit your environment. For example, refine the spike detection (Use Case 1) by setting a threshold appropriate to your typical traffic baseline. Leverage fields like `cs9` (Rule name) to filter out or focus on specific bot categories or custom policies. Since **allowed bot traffic is no longer sent via SIEM as of Dec 2025** (community.imperva.com), your feed is focused on actionable events (blocks/challenges); however, you should periodically review the **action distribution** (Use Case 13) to ensure that your policies are working as intended (e.g., if too many challenges vs. blocks, you might adjust the policy aggressiveness). Also consider using the Visitor ID (`VID`) and Client App Signature (`clappsig`) fields to track unique bot **identities** across sessions – consistent values of `cs4` or `cs5` across different IPs could indicate the same botnet or tool cycling through IP addresses. |

## References

1. **Imperva Cloud WAF SIEM Integration – Log File Structure (Field Reference)** – *Imperva Documentation* (Thales Cybersecurity Documentation Portal) (docs-cybersec.thalesgroup.com) (docs-cybersec.thalesgroup.com) 
2. **Imperva Cloud WAF SIEM Integration – Example Logs** (CEF, LEEF, W3C Samples with Field Labels) – *Imperva Official Docs* (docs-cybersec.thalesgroup.com) (docs-cybersec.thalesgroup.com) 
3. **Imperva Near Real-Time SIEM Log Integration (Advanced Bot Protection)** – *Imperva Documentation* (Cloud WAF User Guide) (docs-cybersec.thalesgroup.com) (docs-cybersec.thalesgroup.com) 
4. **Imperva SIEM Integration Setup for ABP (Google Cloud SecOps)** – *Google Cloud Docs* (describes enabling ABP logs in JSON format) (docs.cloud.google.com) 
5. **Imperva Cloud WAF Release Notes – ABP Logging Update** (Allowlisted traffic removal) – *Imperva Community* (community.imperva.com) 
6. **Imperva Incapsula Logs Downloader Guide** – *Imperva GitHub Documentation* (notes on default Splunk sourcetype naming for CEF) (docs.hunters.ai) 
7. **LogRhythm SIEM Integration Guide for Imperva** – *LogRhythm Docs* (details on Imperva CEF/LEEF field mappings and descriptions) (docs.logrhythm.com) (docs.logrhythm.com)

Sources:
[1] Imperva - docs.hunters.ai - https://docs.hunters.ai/docs/imperva
[2] Near Real-Time SIEM Log Integration - Imperva - https://docs-cybersec.thalesgroup.com/bundle/cloud-application-security/page/siem-log-overview.htm
[3] Log File Structure - Imperva - https://docs-cybersec.thalesgroup.com/bundle/cloud-application-security/page/more/log-file-structure.htm
[4] Collect Imperva Advanced Bot Protection logs | Google Security ... - https://docs.cloud.google.com/chronicle/docs/ingestion/default-parsers/imperva-abp
[5] V 2.0 : Access And Security Events - LogRhythm - https://docs.logrhythm.com/devices/docs/v-2-0-access-and-security-events
[6] Example Logs - Imperva - https://docs-cybersec.thalesgroup.com/bundle/cloud-application-security/page/more/example-logs.htm
[7] Imperva Advanced Bot Mitigation Reports and Policies: An Overview - https://community.imperva.com/blogs/brooks-cunningham1/2020/06/10/imperva-advanced-bot-mitigation-reports-and-polici
[8] Cloud Application Security Release Notes September 21, 2025 - https://community.imperva.com/blogs/seana-murray/2025/09/22/cloud-application-security-release-notes-september
[9] Configure the SIEM Log Integration - Imperva - https://docs-cybersec.thalesgroup.com/bundle/cloud-application-security/page/siem-log-configuration.htm

### USER
index=imperva-bot-mitigation event.action=block
| spath path=server.domain output=domain
| spath path=url.path output=path
| eval location=domain."::".path
| spath path=imperva.abp.bot_behaviors{} output=behaviors_array
| eval behaviors=mvjoin(behaviors_array, ", ")
| spath path=imperva.abp.bot_deciding_condition_names{} output=deciding_array
| eval deciding=mvjoin(deciding_array, ", ")
| spath path=imperva.abp.bot_triggered_condition_names{} output=triggered_array
| eval triggered=mvjoin(triggered_array, ", ")
| fillnull value="-" behaviors deciding triggered
| search location="*::/api/login" deciding="Missing token"
| timechart span=60m c by user_agent.name  
  
use this Splunk query to determine the log type, then craft queries based on this structure

### ASSISTANT
Excellent — this query is extremely informative. It reveals that your Imperva ABP logs are ingested as **structured JSON** (using `spath` for nested field extraction), and it exposes the actual field hierarchy used in your environment. Let me break down the schema and then provide refined use cases.

---

## Observed Log Schema (Structured JSON)

Based on your query, the field structure is:

| **Category** | **Field Path** | **Description** |
|---|---|---|
| **Action** | `event.action` | Mitigation outcome (`block`, `challenge`, etc.) |
| **Server/Site** | `server.domain` | Protected site domain |
| **URL** | `url.path` | Requested URL path |
| **Client IP** | `client.ip` *(inferred)* | Source IP |
| **Geo** | `client.geo.country_iso_code` *(inferred)* | Country code |
| **User Agent** | `user_agent.name` | Parsed browser/client name (e.g., "Chrome", "Python Requests") |
| **User Agent (raw)** | `user_agent.original` *(inferred)* | Full UA string |
| **Bot Behaviors** | `imperva.abp.bot_behaviors{}` | MV array of observed bot behaviors |
| **Deciding Conditions** | `imperva.abp.bot_deciding_condition_names{}` | MV array — the conditions that **decided** the action |
| **Triggered Conditions** | `imperva.abp.bot_triggered_condition_names{}` | MV array — all conditions that **triggered** (superset of deciding) |
| **Bot Type/Classification** | `imperva.abp.bot_type` *(inferred)* | Bot classification label |
| **Visitor ID** | `imperva.abp.vid` *(inferred)* | Unique visitor fingerprint |
| **Request ID** | `event.id` *(inferred)* | Unique event identifier |
| **HTTP Method** | `http.request.method` *(inferred)* | GET, POST, etc. |
| **Status Code** | `http.response.status_code` *(inferred)* | HTTP response code |

> *Fields marked "inferred" follow the standard Imperva JSON/ECS schema and should be validated in your environment via `| fieldsummary` or `| spath`.*

---

## 🔴 Threat Detection Use Cases

### 1. **Credential Stuffing on Login Endpoints — "Missing Token" Attacks**
*Your original query pattern — detect bots hitting login endpoints without valid tokens, a hallmark of credential stuffing tools.*

```splunk
index=imperva-bot-mitigation event.action=block
| spath path=server.domain output=domain
| spath path=url.path output=path
| eval location=domain."::".path
| spath path=imperva.abp.bot_deciding_condition_names{} output=deciding_array
| eval deciding=mvjoin(deciding_array, ", ")
| search location="*::/api/login" deciding="Missing token"
| spath path=client.ip output=src_ip
| stats count AS attempts dc(src_ip) AS unique_ips by domain deciding
| sort - attempts
```

---

### 2. **Top Deciding Conditions Driving Blocks (Attack Technique Breakdown)**
*Understand which ABP detection techniques are firing most often across your estate.*

```splunk
index=imperva-bot-mitigation event.action=block
| spath path=imperva.abp.bot_deciding_condition_names{} output=deciding_array
| mvexpand deciding_array
| stats count AS events by deciding_array
| sort - events
| rename deciding_array AS "Deciding Condition"
```

---

### 3. **Top Bot Behaviors Observed Across Blocked Traffic**
*Map the behavioral fingerprint of bots attacking your sites — e.g., "Aggressive Session", "Device Fingerprint Anomaly", etc.*

```splunk
index=imperva-bot-mitigation event.action=block
| spath path=imperva.abp.bot_behaviors{} output=behaviors_array
| mvexpand behaviors_array
| stats count AS occurrences by behaviors_array
| sort - occurrences
| rename behaviors_array AS "Bot Behavior"
```

---

### 4. **Top Attacking IPs by Volume (with Geo and User Agent)**
*Identify the most prolific bot sources and their characteristics.*

```splunk
index=imperva-bot-mitigation event.action=block
| spath path=client.ip output=src_ip
| spath path=client.geo.country_iso_code output=country
| spath path=user_agent.name output=ua_name
| stats count AS blocked_requests by src_ip country ua_name
| sort - blocked_requests
| head 20
```

---

### 5. **Most Targeted Domains and URL Paths**
*Identify which sites and specific endpoints bots are hammering hardest.*

```splunk
index=imperva-bot-mitigation event.action=block
| spath path=server.domain output=domain
| spath path=url.path output=path
| eval location=domain."::".path
| stats count AS hits by location
| sort - hits
| head 20
```

---

### 6. **Bot Attacks by User Agent Name — Spot Automation Frameworks**
*Surface which client applications (parsed UA names) are most frequently blocked.*

```splunk
index=imperva-bot-mitigation event.action=block
| spath path=user_agent.name output=ua_name
| spath path=user_agent.original output=ua_raw
| stats count AS blocked dc(ua_raw) AS unique_raw_uas by ua_name
| sort - blocked
```

---

### 7. **Detect Distributed Bot Attacks (Many IPs, Same Behavior/Condition)**
*Find coordinated bot campaigns where many IPs share the same deciding condition — indicative of a botnet.*

```splunk
index=imperva-bot-mitigation event.action=block
| spath path=client.ip output=src_ip
| spath path=imperva.abp.bot_deciding_condition_names{} output=deciding_array
| eval deciding=mvjoin(deciding_array, ", ")
| stats dc(src_ip) AS unique_ips count AS total_events by deciding
| where unique_ips > 50
| sort - unique_ips
```

---

### 8. **Hourly Bot Attack Heatmap by Domain**
*Visualize the timing of bot attacks per protected domain — useful for spotting scheduled scraping or attack waves.*

```splunk
index=imperva-bot-mitigation event.action=block
| spath path=server.domain output=domain
| timechart span=1h count by domain
```

---

### 9. **API Endpoint Abuse — High-Rate Bot Hits on API Paths**
*Detect bots specifically targeting API routes.*

```splunk
index=imperva-bot-mitigation event.action=block
| spath path=url.path output=path
| search path="/api/*"
| spath path=client.ip output=src_ip
| spath path=server.domain output=domain
| spath path=imperva.abp.bot_deciding_condition_names{} output=deciding_array
| eval deciding=mvjoin(deciding_array, ", ")
| stats count AS api_hits dc(src_ip) AS unique_ips by domain path deciding
| sort - api_hits
| head 20
```

---

### 10. **Spike Detection — Anomalous Bot Volume per Domain**
*Alert when a specific domain sees bot traffic far above its normal baseline.*

```splunk
index=imperva-bot-mitigation event.action=block
| spath path=server.domain output=domain
| bin span=1h _time
| stats count AS hourly_blocks by _time domain
| eventstats avg(hourly_blocks) AS avg_blocks stdev(hourly_blocks) AS sd_blocks by domain
| eval threshold=avg_blocks + (3 * sd_blocks)
| where hourly_blocks > threshold
| table _time domain hourly_blocks avg_blocks threshold
| sort _time
```

---

### 11. **Combination Attack Fingerprint — Behaviors + Conditions Matrix**
*Correlate bot behaviors with deciding conditions to profile attack toolkits.*

```splunk
index=imperva-bot-mitigation event.action=block
| spath path=imperva.abp.bot_behaviors{} output=behaviors_array
| spath path=imperva.abp.bot_deciding_condition_names{} output=deciding_array
| eval behaviors=mvjoin(behaviors_array, ", ")
| eval deciding=mvjoin(deciding_array, ", ")
| fillnull value="-" behaviors deciding
| stats count AS events by deciding behaviors
| sort - events
| head 30
```

---

### 12. **Single IP Deep Dive — Full Attack Profile**
*Investigate a specific suspicious IP to understand its full bot fingerprint.*

```splunk
index=imperva-bot-mitigation event.action=block
| spath path=client.ip output=src_ip
| search src_ip="<SUSPICIOUS_IP>"
| spath path=server.domain output=domain
| spath path=url.path output=path
| spath path=user_agent.name output=ua_name
| spath path=user_agent.original output=ua_raw
| spath path=imperva.abp.bot_behaviors{} output=behaviors_array
| spath path=imperva.abp.bot_deciding_condition_names{} output=deciding_array
| spath path=imperva.abp.bot_triggered_condition_names{} output=triggered_array
| eval behaviors=mvjoin(behaviors_array, ", ")
| eval deciding=mvjoin(deciding_array, ", ")
| eval triggered=mvjoin(triggered_array, ", ")
| fillnull value="-" behaviors deciding triggered
| table _time domain path ua_name ua_raw deciding triggered behaviors
| sort - _time
```

---

## 🔧 Troubleshooting Use Cases

### 13. **Log Ingestion Health Check — Event Volume Over Time**
*Ensure ABP logs are flowing consistently into Splunk without gaps.*

```splunk
index=imperva-bot-mitigation
| timechart span=15m count AS event_count
| where event_count < 1
```

---

### 14. **Validate ABP-Specific Field Presence**
*Confirm that the critical `imperva.abp.*` nested fields are being properly extracted.*

```splunk
index=imperva-bot-mitigation
| head 1000
| spath path=imperva.abp.bot_behaviors{} output=behaviors
| spath path=imperva.abp.bot_deciding_condition_names{} output=deciding
| spath path=imperva.abp.bot_triggered_condition_names{} output=triggered
| eval has_behaviors=if(isnotnull(behaviors),1,0)
| eval has_deciding=if(isnotnull(deciding),1,0)
| eval has_triggered=if(isnotnull(triggered),1,0)
| stats sum(has_behaviors) AS with_behaviors sum(has_deciding) AS with_deciding sum(has_triggered) AS with_triggered count AS total
```

---

### 15. **Action Distribution Audit**
*Verify what actions ABP is taking — should be `block` and `challenge` only (no `allow` since Dec 2025).*

```splunk
index=imperva-bot-mitigation
| spath path=event.action output=action
| stats count AS events by action
| sort - events
```

---

### 16. **False Positive Investigation — Legitimate Browser Blocks**
*Find blocks where the user agent appears to be a mainstream browser — possible false positives.*

```splunk
index=imperva-bot-mitigation event.action=block
| spath path=user_agent.name output=ua_name
| search ua_name IN ("Chrome", "Firefox", "Safari", "Edge", "Chrome Mobile")
| spath path=server.domain output=domain
| spath path=url.path output=path
| spath path=client.ip output=src_ip
| spath path=imperva.abp.bot_deciding_condition_names{} output=deciding_array
| eval deciding=mvjoin(deciding_array, ", ")
| stats count AS blocked_requests dc(src_ip) AS unique_ips by ua_name domain deciding
| sort - blocked_requests
```

---

### 17. **Check for Duplicate Events (Retransmission Issues)**
*Detect if the same event was ingested more than once, which can skew metrics.*

```splunk
index=imperva-bot-mitigation
| spath path=event.id output=event_id
| stats count AS occurrences by event_id
| where occurrences > 1
| sort - occurrences
```

---

### 18. **Per-Domain Log Coverage Validation**
*Confirm each protected domain is actively sending ABP logs and check last event time.*

```splunk
index=imperva-bot-mitigation
| spath path=server.domain output=domain
| stats latest(_time) AS last_event earliest(_time) AS first_event count AS total_events by domain
| eval last_event=strftime(last_event, "%Y-%m-%d %H:%M:%S")
| eval first_event=strftime(first_event, "%Y-%m-%d %H:%M:%S")
| sort - total_events
```

---

### 19. **Triggered vs. Deciding Conditions Gap Analysis**
*Identify conditions that are frequently triggered but rarely the deciding factor — helps understand ABP's decision-making and tune policies.*

```splunk
index=imperva-bot-mitigation event.action=block
| spath path=imperva.abp.bot_triggered_condition_names{} output=triggered_array
| spath path=imperva.abp.bot_deciding_condition_names{} output=deciding_array
| mvexpand triggered_array
| eval is_deciding=if(mvfind(deciding_array, triggered_array) >= 0, 1, 0)
| stats count AS times_triggered sum(is_deciding) AS times_deciding by triggered_array
| eval deciding_pct=round((times_deciding / times_triggered) * 100, 1)
| sort - times_triggered
| rename triggered_array AS "Condition", times_triggered AS "Triggered", times_deciding AS "Was Deciding", deciding_pct AS "Deciding %"
```

---

### 20. **Raw Event Inspection — Sample Events for Schema Discovery**
*When in doubt, inspect raw JSON events to discover additional fields.*

```splunk
index=imperva-bot-mitigation
| head 5
| spath
| table *
```

---

## Quick Reference: Key `spath` Patterns

```text
spath path=client.ip
spath path=client.geo.country_iso_code
spath path=server.domain
spath path=url.path
spath path=url.query
spath path=http.request.method
spath path=http.response.status_code
spath path=user_agent.name
spath path=user_agent.original
spath path=event.action
spath path=event.id
spath path=imperva.abp.bot_behaviors{}
spath path=imperva.abp.bot_deciding_condition_names{}
spath path=imperva.abp.bot_triggered_condition_names{}
spath path=imperva.abp.bot_type
spath path=imperva.abp.vid
```

> **Tip:** Run **Use Case 20** first in your environment to confirm all available fields and their exact paths — the inferred fields above follow the standard Imperva ABP JSON/ECS schema but your deployment may include additional or slightly different field names.

### USER
index=imperva-bot-mitigation
| spath path=client.ip output=src_ip
| search src_ip="90.209.25.40"
| spath path=server.domain output=domain
| spath path=url.path output=path
| spath path=user_agent.name output=ua_name
| spath path=user_agent.original output=ua_raw
| spath path=imperva.abp.bot_behaviors{} output=behaviors_array
| spath path=imperva.abp.bot_deciding_condition_names{} output=deciding_array
| spath path=imperva.abp.bot_triggered_condition_names{} output=triggered_array
| eval behaviors=mvjoin(behaviors_array, ", ")
| eval deciding=mvjoin(deciding_array, ", ")
| eval triggered=mvjoin(triggered_array, ", ")
| fillnull value="-" behaviors deciding triggered
| table _time domain path ua_name ua_raw deciding triggered behaviors
| sort – _time  
  
I see no results in statistics in Splunk

### ASSISTANT
There are a few potential issues with your query. Let me walk through them:

---

## 🔴 Issue 1: The Dash Character in `sort`

This is very likely your primary problem. Look closely at your last line:

```
| sort – _time
```

That's an **en-dash** (`–`, Unicode U+2013), **not** a hyphen/minus (`-`, Unicode U+002D). Splunk doesn't recognize `–` as the descending sort operator and will silently fail or produce unexpected results.

**Fix:**
```
| sort - _time
```

This is a very common issue when copying queries from Word documents, emails, rich-text editors, or AI-generated text — they auto-correct hyphens to typographic dashes.

---

## 🔴 Issue 2: `event.action` Filter Is Missing

Your original working query had `event.action=block` in the base search, which significantly narrows results. Your current query searches **all** events for that IP. This isn't necessarily wrong, but if the IP only appears in events with a specific action, or if the sheer volume of unfiltered events causes Splunk to time out before reaching that IP, you may get no results.

**Fix — add it back:**
```
index=imperva-bot-mitigation event.action=block
```

---

## 🔴 Issue 3: `spath` + `search` Filtering Is Inefficient

Using `spath` to extract a field and then `| search` to filter on it forces Splunk to extract the field from **every single event** in the index before filtering. This is extremely slow on large datasets and can time out, returning zero results.

**Fix — filter in the base search using the raw JSON value:**
```
index=imperva-bot-mitigation event.action=block "90.209.25.40"
```

By putting the IP as a raw string in the base search, Splunk uses the **bloom filter** on the index to immediately skip buckets that don't contain that string — orders of magnitude faster.

---

## ✅ Corrected Query

```splunk
index=imperva-bot-mitigation event.action=block "90.209.25.40"
| spath path=client.ip output=src_ip
| where src_ip="90.209.25.40"
| spath path=server.domain output=domain
| spath path=url.path output=path
| spath path=user_agent.name output=ua_name
| spath path=user_agent.original output=ua_raw
| spath path=imperva.abp.bot_behaviors{} output=behaviors_array
| spath path=imperva.abp.bot_deciding_condition_names{} output=deciding_array
| spath path=imperva.abp.bot_triggered_condition_names{} output=triggered_array
| eval behaviors=mvjoin(behaviors_array, ", ")
| eval deciding=mvjoin(deciding_array, ", ")
| eval triggered=mvjoin(triggered_array, ", ")
| fillnull value="-" behaviors deciding triggered
| table _time domain path ua_name ua_raw deciding triggered behaviors
| sort - _time
```

### What changed:

| Change | Why |
|---|---|
| Added `"90.209.25.40"` to the **base search** | Leverages Splunk's bloom filters for fast bucket-level filtering |
| Changed `\| search src_ip=` to `\| where src_ip=` | `where` is more reliable for extracted fields; `search` can behave unexpectedly with `spath`-generated fields |
| Added `event.action=block` back | Narrows the dataset before expensive `spath` operations |
| Fixed `–` (en-dash) to `-` (hyphen) in `sort` | Splunk only recognizes the ASCII hyphen-minus as the descending operator |

---

## 🔧 Still No Results? Diagnostic Steps

**Step 1 — Confirm the IP exists at all in the index:**
```splunk
index=imperva-bot-mitigation "90.209.25.40"
| head 5
```

**Step 2 — Check the actual field path for the IP:**
```splunk
index=imperva-bot-mitigation "90.209.25.40"
| head 1
| spath
| table *
```
This will expand all JSON fields — look for where `90.209.25.40` actually lives. It might be `client.ip`, `source.ip`, `src`, or another path.

**Step 3 — Verify your time range:**
Make sure the Splunk time picker covers the period when this IP was active. Try **All Time** temporarily to rule out a time range issue.

**Step 4 — Check if the IP only has non-block actions:**
```splunk
index=imperva-bot-mitigation "90.209.25.40"
| spath path=event.action output=action
| stats count by action
```

This will tell you if the IP exists in the logs but was only `challenge`d or `monitor`ed rather than `block`ed.

### USER
this IP exists in the Imperva dashboard, but in Splunk, when I query this IP it does not ecist

### ASSISTANT
This is a common and important integration issue. The IP exists in the **Imperva Cloud Console** but not in the **Splunk SIEM feed** — which means the events are being generated by Imperva but are **not making it into Splunk**. Let's systematically diagnose this.

---

## Step 1: Confirm the Splunk Index Has Any Data at All

```splunk
index=imperva-bot-mitigation
| stats count earliest(_time) AS first_event latest(_time) AS last_event
| eval first_event=strftime(first_event, "%Y-%m-%d %H:%M:%S")
| eval last_event=strftime(last_event, "%Y-%m-%d %H:%M:%S")
```

**What to look for:**
- If `count = 0` → the entire SIEM feed is broken, not just this IP
- If `last_event` is days/weeks old → log ingestion has stopped
- If data exists but is recent → the feed is working but may be filtered

---

## Step 2: Check What Is Actually In the Index

```splunk
index=imperva-bot-mitigation
| head 10
| spath
| table *
```

Look at the raw events to understand:
- What **actions** are present (`block`, `challenge`, `monitor`)?
- What **domains/sites** are present?
- What **time range** the events cover?

---

## Step 3: Check if the IP's Domain/Site Is Included in the SIEM Feed

The most common root cause is that **not all sites/domains are configured to send logs to SIEM**. In the Imperva console, each site's SIEM integration must be explicitly enabled.

```splunk
index=imperva-bot-mitigation
| spath path=server.domain output=domain
| stats count by domain
| sort - count
```

**Then compare:** Is the domain that the IP `90.209.25.40` was hitting (as shown in the Imperva dashboard) present in these results? If it's **missing**, that site's ABP logs are not configured to forward to your Splunk SIEM connection.

---

## Step 4: Check if Only Certain Actions Are Being Sent

Imperva may be configured to only send **blocked** events to SIEM, while the IP you see in the dashboard may have been **challenged** or **monitored** (not blocked).

Check what the IP's action was in the Imperva dashboard:
- Was it **Blocked**? → Should be in SIEM
- Was it **Challenged (CAPTCHA/JS)**? → May or may not be in SIEM depending on config
- Was it **Monitored only**? → Likely **not** sent to SIEM

As of December 2025, Imperva **removed "allowed" bot traffic from SIEM feeds** entirely. Only actionable events (block/challenge) are forwarded.

---

## Step 5: Check for Time Lag / Delay

Imperva's SIEM log delivery is **near real-time**, but not instant. There can be a delay of **several minutes to hours** depending on the delivery method (S3, SFTP, HEC, etc.).

```splunk
index=imperva-bot-mitigation
| eval lag_seconds=(_indextime - _time)
| stats avg(lag_seconds) AS avg_lag_sec max(lag_seconds) AS max_lag_sec
| eval avg_lag_min=round(avg_lag_sec/60, 1)
| eval max_lag_min=round(max_lag_sec/60, 1)
| table avg_lag_min max_lag_min
```

If the IP's events happened very recently in the Imperva dashboard, they may simply **not have arrived in Splunk yet**.

---

## Step 6: Verify the SIEM Connection Type and Configuration

Check the following in the **Imperva Cloud Console** under **Logs → SIEM Logs**:

| Setting | What to Check |
|---|---|
| **Connection Status** | Is it showing **Active/Connected**? Or is there an error? |
| **Log Type** | Is **"Advanced Bot Protection"** explicitly enabled as a log source? It's separate from WAF Access Logs |
| **Sites Included** | Are **all sites** selected, or only specific ones? The IP's site may be excluded |
| **Delivery Method** | S3, SFTP, Splunk HEC, etc. — each has different failure modes |
| **Format** | JSON (structured) should match your Splunk parsing config |
| **IP Allowlisting** | If using HEC, Imperva's outbound IPs must be allowlisted on your Splunk infrastructure |

---

## Step 7: Check if ABP Logs vs WAF Access Logs Are Confused

This is a subtle but common issue. Imperva has **two separate log streams**:

| Log Type | Contains | Typical Index |
|---|---|---|
| **WAF Access/Security Logs** | All HTTP requests, WAF rule triggers, DDoS events | Often a different index |
| **Advanced Bot Protection Logs** | Bot-specific detections with `imperva.abp.*` fields | `imperva-bot-mitigation` |

It's possible the IP's events are in the **WAF access log stream** but **not** in the **ABP-specific stream**. Check if you have another Imperva index:

```splunk
index=imperva* "90.209.25.40"
| stats count by index sourcetype
```

This searches **all** Imperva-related indexes for the IP.

---

## Summary of Most Likely Root Causes

| # | Cause | Likelihood | How to Confirm |
|---|---|---|---|
| 1 | **ABP SIEM feed not enabled for that site/domain** | 🔴 High | Step 3 — check if domain is present |
| 2 | **Event was "monitored" or "allowed", not "blocked"** | 🔴 High | Check action in Imperva dashboard |
| 3 | **Logs are in a different Splunk index** (WAF vs ABP) | 🟡 Medium | Step 7 — search `index=imperva*` |
| 4 | **SIEM connection is down or erroring** | 🟡 Medium | Check Imperva console connection status |
| 5 | **Ingestion delay** | 🟢 Low | Step 5 — check lag |
| 6 | **ABP log type not selected in SIEM config** | 🔴 High | Step 6 — verify "Advanced Bot Protection" is checked |

Start with **Step 3** and **Step 7** — those will give you the fastest answers.

### USER
In the Imperva index it looks like logs with this IP do not exist at all. But this IP was blocked with status code 456 (Imperva) due to rate-limiting

### ASSISTANT
That's the key finding. **Rate limiting** and **Advanced Bot Protection** are **two separate Imperva security modules** with **different log streams**. This explains exactly why the IP is missing.

---

## The Root Cause

| Module | Description | SIEM Log Type | Your Index |
|---|---|---|---|
| **Advanced Bot Protection (ABP)** | ML-based bot detection, behavioral analysis, device fingerprinting | ABP logs (`imperva.abp.*` fields) | `imperva-bot-mitigation` ✅ configured |
| **Rate Limiting / DDoS Protection** | Threshold-based rules — block after X requests in Y seconds | **WAF Security Events** or **Rate Limiting logs** | ❌ **Not configured or going to a different index** |

The IP was blocked by Imperva's **Rate Limiting engine** (HTTP 456 is Imperva's custom status code for rate-limited requests), **not** by the Advanced Bot Protection module. Therefore, the event was never written to the ABP log stream and never landed in `imperva-bot-mitigation`.

---

## How to Confirm

### Search all Imperva-related indexes:
```splunk
index=imperva* "90.209.25.40"
| stats count by index sourcetype
```

### If nothing comes back, broaden further:
```splunk
index=* "90.209.25.40" sourcetype=imperva*
| stats count by index sourcetype
```

### Or search for the 456 status code specifically:
```splunk
index=imperva* status=456 OR "456"
| head 10
| spath
| table *
```

---

## What Needs to Happen

You need to ensure that **Imperva WAF Security Event logs** (which include rate limiting blocks) are being forwarded to Splunk. In the Imperva Cloud Console:

### Check under **Logs → SIEM Logs → Log Types**:

| Log Type | Includes | Status to Check |
|---|---|---|
| **Advanced Bot Protection** | Bot detections, `imperva.abp.*` fields | ✅ Already enabled (your current feed) |
| **Security Events** | WAF rule triggers, rate limiting (456), ACL blocks, custom rules | ❓ **Likely NOT enabled** |
| **Access Logs** | All HTTP requests (optional — high volume) | ❓ May or may not be needed |

**Enable "Security Events"** in the SIEM configuration to capture rate limiting blocks.

---

## Once Rate Limiting Logs Are Flowing

They will likely arrive in a **different index or sourcetype**. Work with your Splunk admin to determine where they should land. A common setup:

| Index | Content |
|---|---|
| `imperva-bot-mitigation` | ABP events (bot behavioral detections) |
| `imperva-waf` or `imperva-security` | WAF security events (rate limiting, custom rules, ACLs) |
| `imperva-access` | Full access logs (all requests — optional, high volume) |

Once ingested, rate limiting events will use **different field names** than ABP logs. They follow the standard Cloud WAF security event schema rather than the `imperva.abp.*` structure. A typical query for rate-limited requests would look something like:

```splunk
index=imperva-waf
| spath path=event.action output=action
| spath path=client.ip output=src_ip
| spath path=http.response.status_code output=status
| search status=456
| spath path=server.domain output=domain
| spath path=url.path output=path
| spath path=rule.name output=rule
| stats count AS blocked_requests by src_ip domain path rule
| sort - blocked_requests
```

> ⚠️ The exact field paths will depend on the log format (CEF/LEEF/JSON) and may differ from ABP logs. Once the security events start flowing, run `| spath | table *` on a sample event to map the actual schema.

---

## Summary

| Question | Answer |
|---|---|
| **Why is the IP missing from Splunk?** | It was blocked by **Rate Limiting**, not **ABP** — different log stream |
| **Why does it show in the Imperva dashboard?** | The dashboard aggregates **all** Imperva modules (ABP + WAF + Rate Limiting) |
| **What's the 456 status code?** | Imperva's proprietary code for **rate-limited/blocked** requests |
| **What's the fix?** | Enable **Security Events** log type in Imperva's SIEM configuration |
| **Where should those logs go?** | A separate Splunk index (e.g., `imperva-waf`) with its own field extractions |
