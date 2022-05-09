param frontdoor_name string
param ruleset_name string

resource frontdoor 'Microsoft.Cdn/profiles@2021-06-01' existing = {
  name: frontdoor_name
}

resource ruleset 'Microsoft.Cdn/profiles/rulesets@2021-06-01' = {
  parent: frontdoor
  name: ruleset_name
}

output out_ruleset_name string = ruleset.name
output out_ruleset_id string = ruleset.id

