output "page_rule_ids" {
  description = "IDs of created page rules"
  value = {
    for key, rule in cloudflare_page_rule.rules : key => rule.id
  }
}

output "waf_ruleset_ids" {
  description = "IDs of created WAF custom rulesets"
  value = {
    for key, rs in cloudflare_ruleset.waf_custom : key => rs.id
  }
}

output "redirect_ruleset_ids" {
  description = "IDs of created redirect rulesets"
  value = {
    for key, rs in cloudflare_ruleset.redirect_rules : key => rs.id
  }
}

output "rate_limiting_ruleset_ids" {
  description = "IDs of created rate limiting rulesets"
  value = {
    for key, rs in cloudflare_ruleset.rate_limiting : key => rs.id
  }
}
