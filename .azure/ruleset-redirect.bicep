param parent_ruleset_name string
param redirect_name string
param url_path string
param redirect_path string

var lowercase_url = toLower(url_path)

resource ruleset 'Microsoft.Cdn/profiles/rulesets@2021-06-01' existing = {
  name: parent_ruleset_name
}

resource redirect_rule 'Microsoft.Cdn/profiles/rulesets/rules@2021-06-01' = {
  parent: ruleset
  name: redirect_name
  properties: {
    order: 0
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
          customPath: redirect_path
        }
      }
    ]
    matchProcessingBehavior: 'Stop'
  }
  dependsOn: [
    //profiles_lc_frontdoor_name_resource
  ]
}
