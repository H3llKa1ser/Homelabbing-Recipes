## 🏗️ Architecture Pipeline (From Your Diagram)

```
VISITOR (IP: x.x.x.x, Browser Chrome)
│
▼
┌─────────────────────────────────────────────────────────────────┐
│ BotGuard Shield │
│ TYPE: FORCED REDIRECT │
│ REDIRECT_URL: https://google.com │
├─────────┬─────────┬─────────┬─────────┬─────────┤ │
│ FILTER 1│ FILTER 2│ FILTER 3│ FILTER 4│ FILTER 5│ │
│ Browser │ Hosting │ Bot │ Search │Hardware │ │
│Automat. │Provider │ Guard │ Engine │ Virtual.│ │
│ │ │ │ Robots │ │ │
├─────────┴─────────┴─────────┴─────────┴─────────┤ │
│ │
│ ANY FILTER MATCHED? ──YES──► REDIRECT TO GOOGLE.COM │
│ │ │
│ NO │
│ │ │
│ ▼ │
│ ALLOW ACCESS TO WEBSITE │
└──────────────────────────────────────────────────────────────────┘
```

---

## 📁 Complete Project Structure

```
botguard-shield/
├── server.js # Main Express server + 5 filter pipeline
├── filters/
│ ├── filter1-browser-automation.js
│ ├── filter2-hosting-provider.js
│ ├── filter3-botguard.js
│ ├── filter4-search-engine-robots.js
│ └── filter5-hardware-virtualization.js
├── public/
│ ├── index.html # Protected page
│ └── botguard-client.js # Client-side detection script
├── data/
│ └── hosting-ranges.json # Cached hosting IP ranges
├── package.json
└── .env
```

---

## 📦 package.json

```json
{
"name": "botguard-shield",
"version": "1.0.0",
"description": "5-Layer Bot Protection Pipeline",
"main": "server.js",
"scripts": {
"start": "node server.js",
"dev": "nodemon server.js"
},
"dependencies": {
"express": "^4.18.2",
"express-rate-limit": "^7.1.4",
"ip-range-check": "^0.2.0",
"node-fetch": "^2.7.0",
"dotenv": "^16.3.1",
"ua-parser-js": "^1.0.37"
},
"devDependencies": {
"nodemon": "^3.0.2"
}
}
```

---

## ⚙️ .env

```env
PORT=3000
REDIRECT_URL=https://www.google.com
LOG_BLOCKED=true
BYPASS_KEY=your-secret-bypass-key-here
```

---

## 🔵 FILTER 1 — Browser Automation Detection

```javascript
// filters/filter1-browser-automation.js
// =============================================
// FILTER 1: BROWSER AUTOMATION DETECTION
// Detects: Selenium, Puppeteer, Playwright,
// PhantomJS, Nightmare, CasperJS,
// Headless browsers, HTTP libraries
// =============================================

const AUTOMATION_UA_PATTERNS = [
/selenium/i,
/puppeteer/i,
/playwright/i,
/headlesschrome/i,
/headless/i,
/phantomjs/i,
/nightmare/i,
/casperjs/i,
/webdriver/i,
/chromedriver/i,
/geckodriver/i,

// HTTP libraries (not real browsers)
/python-requests/i,
/python-urllib/i,
/python-aiohttp/i,
/go-http-client/i,
/java\//i,
/apache-httpclient/i,
/okhttp/i,
/libwww-perl/i,
/mechanize/i,
/scrapy/i,
/node-fetch/i,
/axios/i,
/undici/i,
/got\//i,
/superagent/i,
/request\//i,
/wget/i,
/curl/i,
/httpie/i,
/lwp-trivial/i,
/postman/i,
/insomnia/i,
/rest-client/i,
/http_request/i,
/ruby/i,
/perl/i,
/php\//i,
/colly/i,
];

// Headers that real browsers always send
const REQUIRED_BROWSER_HEADERS = [
"accept",
"accept-language",
"accept-encoding",
];

// Suspicious header combinations
const SUSPICIOUS_HEADERS = [
"x-requested-with", // Only sent by AJAX, not page loads
];

function filter1_BrowserAutomation(req) {
const ua = req.headers["user-agent"] || "";
const result = {
filterName: "FILTER_1_BROWSER_AUTOMATION",
passed: true,
reason: null,
details: {},
};

// ── CHECK 1A: Empty or missing User-Agent ──
if (!ua || ua.trim() === "") {
result.passed = false;
result.reason = "Empty or missing User-Agent header";
result.details.userAgent = "(empty)";
return result;
}

// ── CHECK 1B: Known automation/bot User-Agent patterns ──
for (const pattern of AUTOMATION_UA_PATTERNS) {
if (pattern.test(ua)) {
result.passed = false;
result.reason = `Automation UA pattern matched: ${pattern}`;
result.details.userAgent = ua;
result.details.matchedPattern = pattern.toString();
return result;
}
}

// ── CHECK 1C: Missing required browser headers ──
for (const header of REQUIRED_BROWSER_HEADERS) {
if (!req.headers[header] || req.headers[header].trim() === "") {
result.passed = false;
result.reason = `Missing required browser header: ${header}`;
result.details.missingHeader = header;
result.details.userAgent = ua;
return result;
}
}

// ── CHECK 1D: Suspicious Accept-Language ──
const acceptLang = req.headers["accept-language"] || "";
if (acceptLang === "*" || acceptLang === "en") {
result.passed = false;
result.reason = `Suspicious Accept-Language value: "${acceptLang}"`;
result.details.acceptLanguage = acceptLang;
return result;
}

// ── CHECK 1E: Connection header anomaly ──
// Real browsers rarely send "Connection: close" on HTTP/1.1
if (
req.httpVersion === "1.1" &&
req.headers["connection"] &&
req.headers["connection"].toLowerCase() === "close"
) {
result.passed = false;
result.reason = "HTTP/1.1 with Connection: close (library behavior)";
return result;
}

// ── CHECK 1F: UA claims Chrome but no sec-ch-ua header ──
// Modern Chrome (v89+) always sends Client Hints
if (/Chrome\/(\d+)/.test(ua)) {
const chromeVersion = parseInt(RegExp.$1);
if (chromeVersion >= 89 && !req.headers["sec-ch-ua"]) {
result.passed = false;
result.reason = `Chrome ${chromeVersion} without sec-ch-ua header (likely automation)`;
result.details.chromeVersion = chromeVersion;
return result;
}
}

return result;
}

module.exports = filter1_BrowserAutomation;
```

---

## 🔵 FILTER 2 — Hosting Provider / Data Center IP Detection

```javascript
// filters/filter2-hosting-provider.js
// =============================================
// FILTER 2: HOSTING PROVIDER / DATA CENTER
// Detects: AWS, GCP, Azure, DigitalOcean,
// Linode, Vultr, OVH, Hetzner,
// Proxies, VPNs, Data Centers
// =============================================

const dns = require("dns").promises;
const fs = require("fs");
const path = require("path");
const fetch = require("node-fetch");

// Hosting provider keywords for rDNS lookup
const HOSTING_RDNS_KEYWORDS = [
"amazon", "amazonaws", "aws",
"digitalocean",
"linode", "akamai",
"vultr",
"ovh", "ovhcloud",
"hetzner",
"google-cloud", "googlecloud", "cloud.google",
"azure", "microsoft",
"oracle", "oraclecloud",
"cloudflare",
"heroku",
"rackspace",
"scaleway",
"contabo",
"kamatera",
"hostinger",
"hostgator",
"godaddy",
"bluehost",
"dreamhost",
"ionos",
"leaseweb",
"softlayer",
"choopa", // Vultr parent
"cogent",
"servercentral",
"quadranet",
"psychz",
"colocrossing",
"reliablesite",
"buyvm",
"hostwinds",
"interserver",
];

// IP Reputation API cache
const ipCache = new Map();
const CACHE_TTL = 60 * 60 * 1000; // 1 hour

// In-memory CIDR ranges (loaded from cloud providers)
let hostingCIDRs = [];
let lastCIDRLoad = 0;
const CIDR_REFRESH_INTERVAL = 24 * 60 * 60 * 1000; // 24 hours

// ─────────────────────────────────────────────
// Load cloud provider IP ranges
// ─────────────────────────────────────────────
async function loadHostingCIDRs() {
const now = Date.now();
if (now - lastCIDRLoad < CIDR_REFRESH_INTERVAL && hostingCIDRs.length > 0) {
return; // Already loaded recently
}

const newCIDRs = [];
const cacheFile = path.join(__dirname, "..", "data", "hosting-ranges.json");

try {
// AWS
const awsResp = await fetch("https://ip-ranges.amazonaws.com/ip-ranges.json", { timeout: 10000 });
const awsData = await awsResp.json();
awsData.prefixes.forEach((p) => newCIDRs.push(p.ip_prefix));
if (awsData.ipv6_prefixes) {
awsData.ipv6_prefixes.forEach((p) => newCIDRs.push(p.ipv6_prefix));
}
} catch (e) {
console.warn("⚠️ Failed to load AWS IP ranges:", e.message);
}

try {
// GCP
const gcpResp = await fetch("https://www.gstatic.com/ipranges/cloud.json", { timeout: 10000 });
const gcpData = await gcpResp.json();
gcpData.prefixes.forEach((p) => {
if (p.ipv4Prefix) newCIDRs.push(p.ipv4Prefix);
if (p.ipv6Prefix) newCIDRs.push(p.ipv6Prefix);
});
} catch (e) {
console.warn("⚠️ Failed to load GCP IP ranges:", e.message);
}

try {
// DigitalOcean (published via CSV, using known ranges)
const doRanges = [
"104.131.0.0/16", "104.236.0.0/16", "128.199.0.0/16",
"134.209.0.0/16", "137.184.0.0/16", "138.68.0.0/16",
"138.197.0.0/16", "139.59.0.0/16", "142.93.0.0/16",
"143.110.0.0/16", "143.198.0.0/16", "144.126.0.0/16",
"146.190.0.0/16", "147.182.0.0/16", "157.230.0.0/16",
"159.65.0.0/16", "159.89.0.0/16", "159.203.0.0/16",
"161.35.0.0/16", "162.243.0.0/16", "163.47.8.0/21",
"164.90.0.0/16", "164.92.0.0/16", "165.22.0.0/16",
"165.227.0.0/16", "167.71.0.0/16", "167.172.0.0/16",
"170.64.0.0/16", "174.138.0.0/16", "178.128.0.0/16",
"178.62.0.0/16", "188.166.0.0/16", "192.241.0.0/16",
"198.199.64.0/18", "198.211.96.0/19", "206.81.0.0/16",
"206.189.0.0/16", "207.154.192.0/18", "209.97.128.0/17",
"45.55.0.0/16", "46.101.0.0/16", "64.225.0.0/16",
"67.205.128.0/17", "68.183.0.0/16"
];
doRanges.forEach((r) => newCIDRs.push(r));
} catch (e) {}

try {
// Vultr known ranges
const vultrRanges = [
"45.32.0.0/15", "45.63.0.0/16", "45.76.0.0/15",
"45.77.0.0/16", "64.156.0.0/16", "66.42.0.0/16",
"78.141.192.0/18", "80.240.16.0/20", "95.179.128.0/17",
"104.156.224.0/19", "104.207.128.0/17", "108.61.0.0/16",
"136.244.64.0/18", "137.220.32.0/19", "139.180.128.0/17",
"140.82.0.0/16", "141.164.32.0/19", "144.202.0.0/16",
"149.28.0.0/16", "149.248.0.0/16", "155.138.128.0/17",
"192.248.144.0/20", "199.247.0.0/16", "207.148.0.0/17",
"209.250.224.0/19", "216.128.128.0/17"
];
vultrRanges.forEach((r) => newCIDRs.push(r));
} catch (e) {}

if (newCIDRs.length > 0) {
hostingCIDRs = newCIDRs;
lastCIDRLoad = now;

// Save to cache file
try {
const dir = path.dirname(cacheFile);
if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
fs.writeFileSync(cacheFile, JSON.stringify(hostingCIDRs, null, 2));
} catch (e) {}

console.log(`✅ Filter 2: Loaded ${hostingCIDRs.length} hosting CIDR ranges`);
} else {
// Try loading from cache file
try {
if (fs.existsSync(cacheFile)) {
hostingCIDRs = JSON.parse(fs.readFileSync(cacheFile, "utf8"));
lastCIDRLoad = now;
console.log(`✅ Filter 2: Loaded ${hostingCIDRs.length} ranges from cache`);
}
} catch (e) {}
}
}

// ─────────────────────────────────────────────
// Simple CIDR matching (no external dependency needed)
// ─────────────────────────────────────────────
function ipToLong(ip) {
const parts = ip.split(".").map(Number);
return ((parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8) | parts[3]) >>> 0;
}

function isIPInCIDR(ip, cidr) {
if (ip.includes(":")) return false; // Skip IPv6 for now
if (cidr.includes(":")) return false;
try {
const [range, bits] = cidr.split("/");
const mask = ~(2 ** (32 - parseInt(bits)) - 1) >>> 0;
return (ipToLong(ip) & mask) === (ipToLong(range) & mask);
} catch {
return false;
}
}

function isHostingIP(ip) {
for (const cidr of hostingCIDRs) {
if (isIPInCIDR(ip, cidr)) return true;
}
return false;
}

// ─────────────────────────────────────────────
// Reverse DNS lookup
// ─────────────────────────────────────────────
async function checkReverseDNS(ip) {
try {
const hostnames = await dns.reverse(ip);
for (const hostname of hostnames) {
const lower = hostname.toLowerCase();
for (const keyword of HOSTING_RDNS_KEYWORDS) {
if (lower.includes(keyword)) {
return { isHosting: true, hostname, matchedKeyword: keyword };
}
}
}
} catch (e) {
// rDNS failed — not conclusive
}
return { isHosting: false };
}

// ─────────────────────────────────────────────
// IP Reputation API (ip-api.com — free tier)
// ─────────────────────────────────────────────
async function checkIPReputation(ip) {
// Check cache first
if (ipCache.has(ip)) {
const cached = ipCache.get(ip);
if (Date.now() - cached.timestamp < CACHE_TTL) return cached.data;
}

try {
const resp = await fetch(
`http://ip-api.com/json/${ip}?fields=status,hosting,proxy,org,as,isp`,
{ timeout: 5000 }
);
const data = await resp.json();

if (data.status === "success") {
const result = {
isHosting: data.hosting || false,
isProxy: data.proxy || false,
org: data.org || "",
isp: data.isp || "",
as: data.as || "",
};
ipCache.set(ip, { data: result, timestamp: Date.now() });
return result;
}
} catch (e) {}

return { isHosting: false, isProxy: false, org: "", isp: "", as: "" };
}

// ─────────────────────────────────────────────
// MAIN FILTER FUNCTION
// ─────────────────────────────────────────────
async function filter2_HostingProvider(req) {
const ip = req.ip || req.connection.remoteAddress || "";
// Clean IPv6-mapped IPv4
const cleanIP = ip.replace(/^::ffff:/, "");

const result = {
filterName: "FILTER_2_HOSTING_PROVIDER",
passed: true,
reason: null,
details: { ip: cleanIP },
};

// Ensure CIDRs are loaded
await loadHostingCIDRs();

// ── CHECK 2A: CIDR range match ──
if (isHostingIP(cleanIP)) {
result.passed = false;
result.reason = `IP ${cleanIP} matches known hosting provider CIDR range`;
return result;
}

// ── CHECK 2B: Reverse DNS lookup ──
const rdns = await checkReverseDNS(cleanIP);
if (rdns.isHosting) {
result.passed = false;
result.reason = `Reverse DNS indicates hosting provider: ${rdns.hostname} (${rdns.matchedKeyword})`;
result.details.rdnsHostname = rdns.hostname;
result.details.matchedKeyword = rdns.matchedKeyword;
return result;
}

// ── CHECK 2C: IP Reputation API ──
const reputation = await checkIPReputation(cleanIP);
if (reputation.isHosting) {
result.passed = false;
result.reason = `IP flagged as data center/hosting: ${reputation.org} (${reputation.as})`;
result.details.org = reputation.org;
result.details.isp = reputation.isp;
result.details.as = reputation.as;
return result;
}

if (reputation.isProxy) {
result.passed = false;
result.reason = `IP flagged as proxy/VPN: ${reputation.org} (${reputation.as})`;
result.details.org = reputation.org;
result.details.isp = reputation.isp;
result.details.as = reputation.as;
return result;
}

return result;
}

module.exports = filter2_HostingProvider;
```

---

## 🔵 FILTER 3 — BotGuard (Behavioral + Client Signals)

```javascript
// filters/filter3-botguard.js
// =============================================
// FILTER 3: BOTGUARD
// Server-side validation of client-side signals
// Validates: PoW tokens, fingerprint data,
// behavioral scores, honeypot traps
// =============================================

const crypto = require("crypto");

// Store for client-side detection reports
const clientReports = new Map();
const REPORT_TTL = 10 * 60 * 1000; // 10 minutes

// Track request patterns per IP
const requestTracker = new Map();

// ─────────────────────────────────────────────
// Proof-of-Work Verification
// ─────────────────────────────────────────────
function verifyProofOfWork(token) {
if (!token || typeof token !== "string") return false;
try {
const lastColon = token.lastIndexOf(":");
if (lastColon === -1) return false;
const challenge = token.substring(0, lastColon);
const nonce = token.substring(lastColon + 1);

// Verify the hash has required leading zeros
const hash = crypto
.createHash("sha256")
.update(challenge + ":" + nonce)
.digest("hex");

if (!hash.startsWith("0000")) return false;

// Verify the challenge timestamp is recent (within 5 minutes)
const parts = challenge.split(".");
if (parts.length > 0) {
const timestamp = parseInt(parts[0], 36);
const age = Date.now() - timestamp;
if (age > 5 * 60 * 1000 || age < 0) return false;
}

return true;
} catch {
return false;
}
}

// ─────────────────────────────────────────────
// Request Pattern Analysis
// ─────────────────────────────────────────────
function analyzeRequestPattern(ip) {
const now = Date.now();
const windowMs = 60 * 1000; // 1 minute window

if (!requestTracker.has(ip)) {
requestTracker.set(ip, []);
}

const timestamps = requestTracker.get(ip);
timestamps.push(now);

// Remove old entries
while (timestamps.length > 0 && now - timestamps[0] > windowMs) {
timestamps.shift();
}

const count = timestamps.length;

// Check for suspicious patterns
const result = { suspicious: false, reason: "" };

// Too many requests in 1 minute
if (count > 60) {
result.suspicious = true;
result.reason = `High request rate: ${count} requests/minute`;
return result;
}

// Check for perfectly timed requests (bot behavior)
if (count >= 5) {
const intervals = [];
for (let i = 1; i < timestamps.length; i++) {
intervals.push(timestamps[i] - timestamps[i - 1]);
}
const avgInterval = intervals.reduce((a, b) => a + b, 0) / intervals.length;
const variance =
intervals.reduce((sum, val) => sum + Math.pow(val - avgInterval, 2), 0) /
intervals.length;
const stdDev = Math.sqrt(variance);

// Very low variance = perfectly timed = bot
if (stdDev < 50 && count > 10) {
result.suspicious = true;
result.reason = `Machine-like request timing (stdDev: ${stdDev.toFixed(1)}ms)`;
}
}

return result;
}

// ─────────────────────────────────────────────
// Store client-side detection report
// ─────────────────────────────────────────────
function storeClientReport(ip, report) {
clientReports.set(ip, {
data: report,
timestamp: Date.now(),
});

// Auto-expire
setTimeout(() => clientReports.delete(ip), REPORT_TTL);
}

// ─────────────────────────────────────────────
// MAIN FILTER FUNCTION
// ─────────────────────────────────────────────
function filter3_BotGuard(req) {
const ip = req.ip || req.connection.remoteAddress || "";
const cleanIP = ip.replace(/^::ffff:/, "");

const result = {
filterName: "FILTER_3_BOTGUARD",
passed: true,
reason: null,
details: { ip: cleanIP },
};

// ── CHECK 3A: Proof-of-Work token (for API routes) ──
if (req.path.startsWith("/api/") && req.path !== "/api/bot-report") {
const powToken = req.headers["x-pow-token"];
if (!verifyProofOfWork(powToken)) {
result.passed = false;
result.reason = "Invalid or missing Proof-of-Work token";
result.details.powToken = powToken ? "(invalid)" : "(missing)";
return result;
}
}

// ── CHECK 3B: Client-side bot report ──
if (clientReports.has(cleanIP)) {
const report = clientReports.get(cleanIP).data;
if (report && report.isBot === true) {
result.passed = false;
result.reason = `Client-side detection: ${report.reason || "bot detected"}`;
result.details.clientReport = report;
return result;
}
}

// ── CHECK 3C: Request pattern analysis ──
const patternResult = analyzeRequestPattern(cleanIP);
if (patternResult.suspicious) {
result.passed = false;
result.reason = patternResult.reason;
return result;
}

// ── CHECK 3D: Honeypot trap check ──
if (req.path === "/trap-endpoint-do-not-follow" ||
req.path === "/admin-login" ||
req.path === "/wp-admin" ||
req.path === "/xmlrpc.php" ||
req.path === "/.env" ||
req.path === "/config.php") {
result.passed = false;
result.reason = `Honeypot/trap URL accessed: ${req.path}`;
return result;
}

// ── CHECK 3E: Honeypot form fields ──
if (req.method === "POST" && req.body) {
const honeypotFields = [
"website_url_hp", "fax_number_hp", "middle_name_hp",
"phone2_hp", "address2_hp", "company_hp"
];
for (const field of honeypotFields) {
if (req.body[field] && req.body[field].trim() !== "") {
result.passed = false;
result.reason = `Honeypot form field filled: ${field}`;
return result;
}
}
}

// ── CHECK 3F: TLS fingerprint check (if available via proxy header) ──
const ja3 = req.headers["x-ja3-hash"] || "";
const knownBotJA3 = [
"e7d705a3286e19ea42f587b344ee6865", // Python requests
"b32309a26951912be7dba376398abc3b", // Go default
"3b5074b1b5d032e5620f69f9f700ff0e", // Node.js default
];
if (ja3 && knownBotJA3.includes(ja3)) {
result.passed = false;
result.reason = `Known bot TLS fingerprint (JA3): ${ja3}`;
return result;
}

return result;
}

// Export both the filter and the report storage function
module.exports = filter3_BotGuard;
module.exports.storeClientReport = storeClientReport;
```

---

## 🔵 FILTER 4 — Search Engine Robots

```javascript
// filters/filter4-search-engine-robots.js
// =============================================
// FILTER 4: SEARCH ENGINE ROBOTS
// Detects: Crawlers, spiders, bots claiming
// to be search engines but unverified
// Allows: Verified Google, Bing, Yahoo, Yandex
// =============================================

const dns = require("dns").promises;

// Verified search engine bot definitions
// Each bot has: UA patterns + valid rDNS domains
const VERIFIED_BOTS = {
Google: {
uaPatterns: [/Googlebot/i, /Google-Site-Verification/i, /AdsBot-Google/i, /Mediapartners-Google/i],
rdnsDomains: [".googlebot.com", ".google.com"],
},
Bing: {
uaPatterns: [/bingbot/i, /msnbot/i, /BingPreview/i],
rdnsDomains: [".search.msn.com"],
},
Yahoo: {
uaPatterns: [/Slurp/i],
rdnsDomains: [".crawl.yahoo.net"],
},
Yandex: {
uaPatterns: [/YandexBot/i, /YandexImages/i, /YandexMobileBot/i],
rdnsDomains: [".yandex.com", ".yandex.net", ".yandex.ru"],
},
Baidu: {
uaPatterns: [/Baiduspider/i],
rdnsDomains: [".crawl.baidu.com", ".crawl.baidu.jp"],
},
DuckDuckGo: {
uaPatterns: [/DuckDuckBot/i],
rdnsDomains: [".duckduckgo.com"],
},
Apple: {
uaPatterns: [/Applebot/i],
rdnsDomains: [".applebot.apple.com"],
},
};

// Generic crawler/spider UA patterns (always block these)
const GENERIC_CRAWLER_PATTERNS = [
/bot/i,
/crawl/i,
/spider/i,
/scraper/i,
/fetch/i,
/archiver/i,
/slurp/i,

// Specific known bad bots
/AhrefsBot/i,
/SemrushBot/i,
/MJ12bot/i,
/DotBot/i,
/BLEXBot/i,
/SearchmetricsBot/i,
/Sogou/i,
/Exabot/i,
/facebot/i, // Facebook crawler (may want to allow)
/ia_archiver/i,
/MegaIndex/i,
/BUbiNG/i,
/Qwantify/i,
/CCBot/i,
/Uptimebot/i,
/linkdexbot/i,
/GrapeshotCrawler/i,
/PetalBot/i,
/Bytespider/i,
/GPTBot/i,
/ChatGPT-User/i,
/ClaudeBot/i,
/anthropic-ai/i,
/cohere-ai/i,
];

// ─────────────────────────────────────────────
// Verify a search engine bot via reverse DNS
// Forward-confirmed reverse DNS (FCrDNS)
// ─────────────────────────────────────────────
async function verifyBotViaDNS(ip, botConfig) {
try {
// Step 1: Reverse DNS lookup
const hostnames = await dns.reverse(ip);

for (const hostname of hostnames) {
const lower = hostname.toLowerCase();

// Check if hostname matches expected domain
for (const domain of botConfig.rdnsDomains) {
if (lower.endsWith(domain)) {
// Step 2: Forward DNS verification
try {
const addresses = await dns.resolve4(hostname);
if (addresses.includes(ip)) {
return {
verified: true,
hostname: hostname,
method: "FCrDNS",
};
}
} catch (e) {}

// Try IPv6 forward lookup too
try {
const addresses6 = await dns.resolve6(hostname);
if (addresses6.includes(ip)) {
return {
verified: true,
hostname: hostname,
method: "FCrDNS-IPv6",
};
}
} catch (e) {}
}
}
}
} catch (e) {
// rDNS failed
}

return { verified: false };
}

// ─────────────────────────────────────────────
// MAIN FILTER FUNCTION
// ─────────────────────────────────────────────
async function filter4_SearchEngineRobots(req) {
const ua = req.headers["user-agent"] || "";
const ip = (req.ip || req.connection.remoteAddress || "").replace(/^::ffff:/, "");

const result = {
filterName: "FILTER_4_SEARCH_ENGINE_ROBOTS",
passed: true,
reason: null,
details: { ip, userAgent: ua },
};

// ── CHECK 4A: Is UA claiming to be a known search engine bot? ──
for (const [botName, config] of Object.entries(VERIFIED_BOTS)) {
for (const pattern of config.uaPatterns) {
if (pattern.test(ua)) {
// UA claims to be this bot — verify via DNS
const verification = await verifyBotViaDNS(ip, config);

if (verification.verified) {
// ✅ Genuine search engine bot — ALLOW (pass this filter)
result.details.verifiedBot = botName;
result.details.hostname = verification.hostname;
console.log(
`✅ Filter 4: Verified ${botName} from ${ip} (${verification.hostname})`
);
return result; // passed = true
} else {
// ❌ Fake bot — claiming to be search engine but DNS doesn't match
result.passed = false;
result.reason = `Fake ${botName}: UA claims to be ${botName} but DNS verification failed`;
result.details.claimedBot = botName;
return result;
}
}
}
}

// ── CHECK 4B: Is UA matching generic crawler patterns? ──
for (const pattern of GENERIC_CRAWLER_PATTERNS) {
if (pattern.test(ua)) {
result.passed = false;
result.reason = `Generic crawler/bot UA detected: ${pattern}`;
result.details.matchedPattern = pattern.toString();
return result;
}
}

// ── CHECK 4C: robots.txt enforcement ──
// If request is for sensitive paths that robots.txt disallows
const protectedPaths = [
"/admin", "/dashboard", "/api/private",
"/user", "/account", "/checkout", "/cart",
];
const isProtectedPath = protectedPaths.some((p) => req.path.startsWith(p));

// If any bot-like header pattern + protected path
if (isProtectedPath) {
// Check for non-browser behavior on protected paths
const hasReferer = !!req.headers["referer"];
const hasCookie = !!req.headers["cookie"];

if (!hasReferer && !hasCookie) {
// Direct access to protected path without referer/cookies = suspicious
// But only flag if other signals also look bot-like
const acceptHeader = req.headers["accept"] || "";
if (!acceptHeader.includes("text/html")) {
result.passed = false;
result.reason = `Non-browser access to protected path: ${req.path}`;
return result;
}
}
}

return result;
}

module.exports = filter4_SearchEngineRobots;
```

---

## 🔵 FILTER 5 — Hardware Virtualization Detection

```javascript
// filters/filter5-hardware-virtualization.js
// =============================================
// FILTER 5: HARDWARE VIRTUALIZATION
// Detects: VMware, VirtualBox, Hyper-V, QEMU,
// KVM, Parallels, RDP Servers,
// Virtual GPUs, Emulated hardware
// =============================================

// This filter primarily relies on client-side
// signals sent to the server. The server validates
// and makes the final decision.

// Store for client VM reports
const vmReports = new Map();
const VM_REPORT_TTL = 10 * 60 * 1000; // 10 minutes

// ─────────────────────────────────────────────
// Known VM/Virtual GPU indicators
// ─────────────────────────────────────────────
const VM_GPU_KEYWORDS = [
"swiftshader",
"llvmpipe",
"mesa",
"virtualbox",
"vmware",
"parallels",
"hyper-v",
"qemu",
"microsoft basic render",
"microsoft basic display",
"google swiftshader",
"virgl",
"virtio",
"bhyve",
"kvm",
"xen",
"bochs",
"innotek", // VirtualBox parent
"red hat virtio",
"amazon elastic",
"cirrus logic", // Common in VMs
];

// ─────────────────────────────────────────────
// Store client-side VM detection report
// ─────────────────────────────────────────────
function storeVMReport(ip, report) {
vmReports.set(ip, {
data: report,
timestamp: Date.now(),
});
setTimeout(() => vmReports.delete(ip), VM_REPORT_TTL);
}

// ─────────────────────────────────────────────
// Validate VM report from client
// ─────────────────────────────────────────────
function validateClientVMReport(report) {
if (!report || typeof report !== "object") return { isVM: false };

const indicators = [];

// Check GPU renderer
if (report.gpuRenderer) {
const rendererLower = report.gpuRenderer.toLowerCase();
for (const keyword of VM_GPU_KEYWORDS) {
if (rendererLower.includes(keyword)) {
indicators.push(`VM GPU: ${report.gpuRenderer}`);
break;
}
}
}

// Check GPU vendor
if (report.gpuVendor) {
const vendorLower = report.gpuVendor.toLowerCase();
for (const keyword of VM_GPU_KEYWORDS) {
if (vendorLower.includes(keyword)) {
indicators.push(`VM GPU Vendor: ${report.gpuVendor}`);
break;
}
}
}

// Check hardware concurrency (VMs often have 1-2 cores)
if (report.hardwareConcurrency !== undefined && report.hardwareConcurrency <= 1) {
indicators.push(`Low CPU cores: ${report.hardwareConcurrency}`);
}

// Check device memory (VMs often have ≤2GB)
if (report.deviceMemory !== undefined && report.deviceMemory < 1) {
indicators.push(`Low memory: ${report.deviceMemory}GB`);
}

// Check screen dimensions (VMs often have specific resolutions)
if (report.screenWidth && report.screenHeight) {
const vmResolutions = [
[800, 600], [1024, 768], [1280, 800],
];
for (const [w, h] of vmResolutions) {
if (report.screenWidth === w && report.screenHeight === h) {
// Not conclusive alone, but adds to score
indicators.push(`Common VM resolution: ${w}x${h}`);
break;
}
}
}

// Check color depth
if (report.colorDepth !== undefined && report.colorDepth < 16) {
indicators.push(`Low color depth: ${report.colorDepth}`);
}

// Battery API (VMs usually report 100% always charging)
if (report.battery) {
if (
report.battery.charging === true &&
report.battery.chargingTime === 0 &&
report.battery.level === 1
) {
indicators.push("Virtual battery (always 100%, always charging)");
}
}

// No media devices (VMs often have none)
if (report.mediaDeviceCount !== undefined && report.mediaDeviceCount === 0) {
indicators.push("No media devices (camera/mic)");
}

// Canvas fingerprint is blank/default
if (report.canvasBlank === true) {
indicators.push("Canvas fingerprint is blank (headless/VM)");
}

// WebGL not available
if (report.webglAvailable === false) {
indicators.push("WebGL not available");
}

// Computation speed (VMs with shared CPU are slower)
if (report.computeTimeMs !== undefined && report.computeTimeMs > 100) {
indicators.push(`Slow computation: ${report.computeTimeMs}ms`);
}

// Touch support mismatch (desktop claiming touch or vice versa)
if (report.touchSupport !== undefined && report.platform) {
if (
report.touchSupport === true &&
/Win|Mac|Linux/.test(report.platform) &&
!/tablet|mobile|android|ipad/i.test(report.userAgent || "")
) {
// Desktop with touch — could be VM touch emulation
// Not conclusive alone
}
}

return {
isVM: indicators.length >= 2, // 2+ indicators = likely VM
indicators: indicators,
indicatorCount: indicators.length,
};
}

// ─────────────────────────────────────────────
// MAIN FILTER FUNCTION
// ─────────────────────────────────────────────
function filter5_HardwareVirtualization(req) {
const ip = (req.ip || req.connection.remoteAddress || "").replace(/^::ffff:/, "");

const result = {
filterName: "FILTER_5_HARDWARE_VIRTUALIZATION",
passed: true,
reason: null,
details: { ip },
};

// ── CHECK 5A: Check stored VM report from client-side ──
if (vmReports.has(ip)) {
const report = vmReports.get(ip).data;
const validation = validateClientVMReport(report);

if (validation.isVM) {
result.passed = false;
result.reason = `Hardware virtualization detected (${validation.indicatorCount} indicators)`;
result.details.indicators = validation.indicators;
result.details.rawReport = report;
return result;
}
}

// ── CHECK 5B: Inline client report (sent with request) ──
if (req.headers["x-vm-report"]) {
try {
const inlineReport = JSON.parse(req.headers["x-vm-report"]);
const validation = validateClientVMReport(inlineReport);

if (validation.isVM) {
result.passed = false;
result.reason = `Hardware virtualization detected via inline report (${validation.indicatorCount} indicators)`;
result.details.indicators = validation.indicators;
return result;
}
} catch (e) {}
}

// ── CHECK 5C: Server-side heuristics ──
// Some VMs/RDP have specific UA patterns
const ua = req.headers["user-agent"] || "";

// RDP web clients
if (/RemoteDesktop|RDP|TeamViewer|AnyDesk|VNC/i.test(ua)) {
result.passed = false;
result.reason = `Remote desktop client detected in UA: ${ua}`;
return result;
}

return result;
}

module.exports = filter5_HardwareVirtualization;
module.exports.storeVMReport = storeVMReport;
```

---

## 🔴 Main Server — Pipeline Orchestrator

```javascript
// server.js
// =============================================
// BOTGUARD SHIELD — 5-LAYER PIPELINE SERVER
// =============================================
// Architecture:
// VISITOR → [F1] → [F2] → [F3] → [F4] → [F5] → WEBSITE
// ↓ ↓ ↓ ↓ ↓
// google google google google google
// =============================================

require("dotenv").config();

const express = require("express");
const path = require("path");
const UAParser = require("ua-parser-js");

// Import filters
const filter1_BrowserAutomation = require("./filters/filter1-browser-automation");
const filter2_HostingProvider = require("./filters/filter2-hosting-provider");
const filter3_BotGuard = require("./filters/filter3-botguard");
const filter4_SearchEngineRobots = require("./filters/filter4-search-engine-robots");
const filter5_HardwareVirtualization = require("./filters/filter5-hardware-virtualization");

const { storeClientReport } = require("./filters/filter3-botguard");
const { storeVMReport } = require("./filters/filter5-hardware-virtualization");

const app = express();
const PORT = process.env.PORT || 3000;
const REDIRECT_URL = process.env.REDIRECT_URL || "https://www.google.com";
const LOG_BLOCKED = process.env.LOG_BLOCKED === "true";
const BYPASS_KEY = process.env.BYPASS_KEY || "";

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Trust proxy (for correct IP behind reverse proxy)
app.set("trust proxy", true);

// =============================================
// BYPASS KEY (for testing/admin access)
// =============================================
app.use((req, res, next) => {
if (BYPASS_KEY && req.headers["x-bypass-key"] === BYPASS_KEY) {
console.log(`🔑 Bypass key accepted for ${req.ip}`);
return next();
}
next();
});

// =============================================
// CLIENT-SIDE REPORT ENDPOINTS
// (These are EXCLUDED from the filter pipeline)
// =============================================
app.post("/api/bot-report", (req, res) => {
const ip = (req.ip || "").replace(/^::ffff:/, "");
storeClientReport(ip, req.body);
console.log(`📡 Client bot report from ${ip}:`, JSON.stringify(req.body));
res.status(204).end();
});

app.post("/api/vm-report", (req, res) => {
const ip = (req.ip || "").replace(/^::ffff:/, "");
storeVMReport(ip, req.body);
console.log(`📡 Client VM report from ${ip}:`, JSON.stringify(req.body));
res.status(204).end();
});

app.post("/api/bot-log", (req, res) => {
const ip = (req.ip || "").replace(/^::ffff:/, "");
console.log(`📡 Client-side block from ${ip}:`, JSON.stringify(req.body));
res.status(204).end();
});

// =============================================
// 🛡️ MAIN FILTER PIPELINE MIDDLEWARE
// =============================================
// Pipeline: F1 → F2 → F3 → F4 → F5
// If ANY filter fails → redirect to google.com
// =============================================
async function botGuardPipeline(req, res, next) {
// Skip report endpoints
const skipPaths = ["/api/bot-report", "/api/vm-report", "/api/bot-log"];
if (skipPaths.includes(req.path)) return next();

// Skip bypass key holders
if (BYPASS_KEY && req.headers["x-bypass-key"] === BYPASS_KEY) return next();

const ip = (req.ip || req.connection.remoteAddress || "").replace(/^::ffff:/, "");
const ua = req.headers["user-agent"] || "";
const startTime = Date.now();

console.log(`\n${"═".repeat(60)}`);
console.log(`🔍 BOTGUARD PIPELINE START`);
console.log(` IP: ${ip}`);
console.log(` UA: ${ua.substring(0, 80)}${ua.length > 80 ? "..." : ""}`);
console.log(` Path: ${req.method} ${req.path}`);
console.log(`${"─".repeat(60)}`);

// ─── FILTER 1: Browser Automation ───
console.log(` [1/5] Browser Automation...`);
const f1 = filter1_BrowserAutomation(req);
if (!f1.passed) {
return blockAndRedirect(res, f1, ip, startTime);
}
console.log(` [1/5] ✅ PASSED`);

// ─── FILTER 2: Hosting Provider ───
console.log(` [2/5] Hosting Provider...`);
const f2 = await filter2_HostingProvider(req);
if (!f2.passed) {
return blockAndRedirect(res, f2, ip, startTime);
}
console.log(` [2/5] ✅ PASSED`);

// ─── FILTER 3: BotGuard ───
console.log(` [3/5] BotGuard...`);
const f3 = filter3_BotGuard(req);
if (!f3.passed) {
return blockAndRedirect(res, f3, ip, startTime);
}
console.log(` [3/5] ✅ PASSED`);

// ─── FILTER 4: Search Engine Robots ───
console.log(` [4/5] Search Engine Robots...`);
const f4 = await filter4_SearchEngineRobots(req);
if (!f4.passed) {
return blockAndRedirect(res, f4, ip, startTime);
}
console.log(` [4/5] ✅ PASSED`);

// ─── FILTER 5: Hardware Virtualization ───
console.log(` [5/5] Hardware Virtualization...`);
const f5 = filter5_HardwareVirtualization(req);
if (!f5.passed) {
return blockAndRedirect(res, f5, ip, startTime);
}
console.log(` [5/5] ✅ PASSED`);

// ─── ALL FILTERS PASSED ───
const elapsed = Date.now() - startTime;
console.log(`${"─".repeat(60)}`);
console.log(` ✅ ALL 5 FILTERS PASSED (${elapsed}ms)`);
console.log(` → Allowing access to: ${req.path}`);
console.log(`${"═".repeat(60)}\n`);

next();
}

// ─────────────────────────────────────────────
// Block and redirect helper
// ─────────────────────────────────────────────
function blockAndRedirect(res, filterResult, ip, startTime) {
const elapsed = Date.now() - startTime;

console.log(` ❌ FAILED — ${filterResult.filterName}`);
console.log(` Reason: ${filterResult.reason}`);
if (filterResult.details && Object.keys(filterResult.details).length > 0) {
console.log(` Details:`, JSON.stringify(filterResult.details));
}
console.log(`${"─".repeat(60)}`);
console.log(` 🚫 BLOCKED & REDIRECTING TO ${REDIRECT_URL} (${elapsed}ms)`);
console.log(`${"═".repeat(60)}\n`);

// Log to file if enabled
if (LOG_BLOCKED) {
const fs = require("fs");
const logEntry = {
timestamp: new Date().toISOString(),
ip,
filter: filterResult.filterName,
reason: filterResult.reason,
details: filterResult.details,
processingTimeMs: elapsed,
};
fs.appendFileSync(
"blocked.log",
JSON.stringify(logEntry) + "\n"
);
}

// Check if AJAX/API request
const isAjax =
req.xhr ||
(req.headers["accept"] || "").includes("application/json") ||
req.path.startsWith("/api/");

if (isAjax) {
return res.status(403).json({
error: "Access denied",
redirect: REDIRECT_URL,
});
}

// Regular page request — redirect
return res.redirect(302, REDIRECT_URL);
}

// Apply pipeline to all routes
app.use(botGuardPipeline);

// =============================================
// STATIC FILES & ROUTES
// =============================================
app.use(express.static(path.join(__dirname, "public")));

app.get("/", (req, res) => {
res.sendFile(path.join(__dirname, "public", "index.html"));
});

// Example API route (protected by pipeline)
app.get("/api/data", (req, res) => {
res.json({ message: "You passed all 5 filters!", timestamp: Date.now() });
});

// Honeypot trap (handled by Filter 3)
app.all("/trap-endpoint-do-not-follow", (req, res) => {
res.redirect(302, REDIRECT_URL);
});

// =============================================
// START SERVER
// =============================================
app.listen(PORT, () => {
console.log(`
╔══════════════════════════════════════════════════════╗
║ 🛡️ BOTGUARD SHIELD v1.0 ║
║ 5-Layer Protection Pipeline Active ║
╠══════════════════════════════════════════════════════╣
║ ║
║ Filter 1: Browser Automation Detection ║
║ Filter 2: Hosting Provider / Data Center ║
║ Filter 3: BotGuard (PoW + Behavioral) ║
║ Filter 4: Search Engine Robots ║
║ Filter 5: Hardware Virtualization ║
║ ║
║ Redirect URL: ${REDIRECT_URL.padEnd(36)}║
║ Port: ${String(PORT).padEnd(45)}║
║ Logging: ${String(LOG_BLOCKED).padEnd(42)}║
║ ║
╚══════════════════════════════════════════════════════╝
`);
});
```
