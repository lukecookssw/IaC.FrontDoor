param frontdoor_name string
param parent_ruleset_name string
param order int
param redirect_name string
param url_path string
param redirect_path string

var lowercase_url = toLower(url_path)
var lowercase_redirect = toLower((redirect_path))

resource parent 'Microsoft.Cdn/profiles@2021-06-01' existing = {
  name: frontdoor_name
}

resource ruleset 'Microsoft.Cdn/profiles/rulesets@2021-06-01' existing = {
  parent: parent
  name: parent_ruleset_name
}

resource redirect_rule 'Microsoft.Cdn/profiles/rulesets/rules@2021-06-01' = {
  parent: ruleset
  name: redirect_name
  properties: {
    order: order
    conditions: [
      {
        name: 'UrlPath'
        parameters: {
          typeName: 'DeliveryRuleUrlPathMatchConditionParameters'
          operator: 'BeginsWith'
          negateCondition: false
          matchValues: [
            lowercase_url
          ]
          transforms: [
            'Lowercase'
          ]
        }
      }
    ]
    actions: [
      {
        name: 'UrlRedirect'
        parameters: {
          typeName: 'DeliveryRuleUrlRedirectActionParameters'
          redirectType: 'Moved'
          destinationProtocol: 'MatchRequest'
          customPath: lowercase_redirect
        }
      }
    ]
    matchProcessingBehavior: 'Stop'
  }
}
