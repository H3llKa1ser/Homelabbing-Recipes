variable "cloudflare_api_token" {
  description = "Cloudflare API Token with appropriate permissions"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare Account ID"
  type        = string
}

variable "domains" {
  description = "Map of domains (zones) to manage"
  type = map(object({
    zone_id = string

    # Page Rules
    page_rules = optional(list(object({
      target   = string
      priority = number
      actions = object({
        forwarding_url = optional(object({
          url         = string
          status_code = number
        }))
        always_use_https    = optional(bool)
        cache_level         = optional(string)
        browser_cache_ttl   = optional(number)
        edge_cache_ttl      = optional(number)
        ssl                 = optional(string)
        security_level      = optional(string)
        disable_performance = optional(bool)
        disable_security    = optional(bool)
      })
    })), [])

    # Firewall Rules (WAF Custom Rules via Rulesets)
    waf_custom_rules = optional(list(object({
      description = string
      expression  = string
      action      = string  # block, challenge, js_challenge, managed_challenge, skip, log
      enabled     = optional(bool, true)
    })), [])

    # Redirect Rules
    redirect_rules = optional(list(object({
      description        = string
      expression         = string
      target_url         = string
      status_code        = optional(number, 301)
      preserve_query     = optional(bool, false)
    })), [])

    # Rate Limiting Rules
    rate_limiting_rules = optional(list(object({
      description          = string
      expression           = string
      action               = string  # block, challenge, js_challenge, managed_challenge, log
      requests_per_period  = number
      period               = number  # in seconds (10, 60, 120, 300, 600, 3600)
      mitigation_timeout   = optional(number, 60)
    })), [])

    # Transform Rules — HTTP Request Header Modification
    request_header_rules = optional(list(object({
      description = string
      expression  = string
      headers = list(object({
        operation = string  # set, add, remove
        name      = string
        value     = optional(string)
      }))
    })), [])

  }))
}
