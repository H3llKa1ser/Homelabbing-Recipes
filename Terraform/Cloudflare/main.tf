# ──────────────────────────────────────────────
# Locals: Flatten nested structures for for_each
# ──────────────────────────────────────────────
locals {

  # Flatten Page Rules
  page_rules = flatten([
    for domain, config in var.domains : [
      for idx, rule in config.page_rules : {
        key      = "${domain}-pr-${idx}"
        zone_id  = config.zone_id
        target   = rule.target
        priority = rule.priority
        actions  = rule.actions
      }
    ]
  ])

  # Flatten Rate Limiting Rules
  rate_limiting_rules = flatten([
    for domain, config in var.domains : [
      for idx, rule in config.rate_limiting_rules : {
        key                 = "${domain}-rl-${idx}"
        zone_id             = config.zone_id
        description         = rule.description
        expression          = rule.expression
        action              = rule.action
        requests_per_period = rule.requests_per_period
        period              = rule.period
        mitigation_timeout  = rule.mitigation_timeout
      }
    ]
  ])
}

# ──────────────────────────────────────────────
# 1. PAGE RULES
# ──────────────────────────────────────────────
resource "cloudflare_page_rule" "rules" {
  for_each = { for rule in local.page_rules : rule.key => rule }

  zone_id  = each.value.zone_id
  target   = each.value.target
  priority = each.value.priority

  actions {
    # Forwarding URL (redirect)
    dynamic "forwarding_url" {
      for_each = each.value.actions.forwarding_url != null ? [each.value.actions.forwarding_url] : []
      content {
        url         = forwarding_url.value.url
        status_code = forwarding_url.value.status_code
      }
    }

    always_use_https    = each.value.actions.always_use_https
    cache_level         = each.value.actions.cache_level
    browser_cache_ttl   = each.value.actions.browser_cache_ttl
    edge_cache_ttl      = each.value.actions.edge_cache_ttl
    ssl                 = each.value.actions.ssl
    security_level      = each.value.actions.security_level
    disable_performance = each.value.actions.disable_performance
    disable_security    = each.value.actions.disable_security
  }
}

# ──────────────────────────────────────────────
# 2. WAF CUSTOM RULES (Replaces legacy Firewall Rules)
# ──────────────────────────────────────────────
resource "cloudflare_ruleset" "waf_custom" {
  for_each = {
    for domain, config in var.domains : domain => config
    if length(config.waf_custom_rules) > 0
  }

  zone_id     = each.value.zone_id
  name        = "WAF Custom Rules - ${each.key}"
  description = "Custom WAF rules for ${each.key}"
  kind        = "zone"
  phase       = "http_request_firewall_custom"

  dynamic "rules" {
    for_each = each.value.waf_custom_rules
    content {
      description = rules.value.description
      expression  = rules.value.expression
      action      = rules.value.action
      enabled     = rules.value.enabled
    }
  }
}

# ──────────────────────────────────────────────
# 3. REDIRECT RULES (Single Redirects via Rulesets)
# ──────────────────────────────────────────────
resource "cloudflare_ruleset" "redirect_rules" {
  for_each = {
    for domain, config in var.domains : domain => config
    if length(config.redirect_rules) > 0
  }

  zone_id     = each.value.zone_id
  name        = "Redirect Rules - ${each.key}"
  description = "Redirect rules for ${each.key}"
  kind        = "zone"
  phase       = "http_request_dynamic_redirect"

  dynamic "rules" {
    for_each = each.value.redirect_rules
    content {
      description = rules.value.description
      expression  = rules.value.expression
      action      = "redirect"

      action_parameters {
        from_value {
          status_code = rules.value.status_code
          target_url {
            value = rules.value.target_url
          }
          preserve_query_string = rules.value.preserve_query
        }
      }
    }
  }
}

# ──────────────────────────────────────────────
# 4. RATE LIMITING RULES (via Rulesets)
# ──────────────────────────────────────────────
resource "cloudflare_ruleset" "rate_limiting" {
  for_each = {
    for domain, config in var.domains : domain => config
    if length(config.rate_limiting_rules) > 0
  }

  zone_id     = each.value.zone_id
  name        = "Rate Limiting Rules - ${each.key}"
  description = "Rate limiting rules for ${each.key}"
  kind        = "zone"
  phase       = "http_ratelimit"

  dynamic "rules" {
    for_each = each.value.rate_limiting_rules
    content {
      description = rules.value.description
      expression  = rules.value.expression
      action      = rules.value.action

      ratelimit {
        characteristics     = ["cf.colo.id", "ip.src"]
        period              = rules.value.period
        requests_per_period  = rules.value.requests_per_period
        mitigation_timeout   = rules.value.mitigation_timeout
      }
    }
  }
}

# ──────────────────────────────────────────────
# 5. TRANSFORM RULES — Request Header Modification
# ──────────────────────────────────────────────
resource "cloudflare_ruleset" "request_headers" {
  for_each = {
    for domain, config in var.domains : domain => config
    if length(config.request_header_rules) > 0
  }

  zone_id     = each.value.zone_id
  name        = "Request Header Transform - ${each.key}"
  description = "HTTP request header modification rules for ${each.key}"
  kind        = "zone"
  phase       = "http_request_late_transform"

  dynamic "rules" {
    for_each = each.value.request_header_rules
    content {
      description = rules.value.description
      expression  = rules.value.expression
      action      = "rewrite"

      action_parameters {
        dynamic "headers" {
          for_each = rules.value.headers
          content {
            name      = headers.value.name
            operation = headers.value.operation
            value     = headers.value.operation != "remove" ? headers.value.value : null
          }
        }
      }
    }
  }
}
