param profiles_lc_frontdoor_name string

resource profiles_lc_frontdoor_name_resource 'Microsoft.Cdn/profiles@2021-06-01' existing = {
  name: profiles_lc_frontdoor_name
}

resource profiles_lc_frontdoor_name_ConsultingRedirects 'Microsoft.Cdn/profiles/rulesets@2021-06-01' = {
  parent: profiles_lc_frontdoor_name_resource
  name: 'ConsultingRedirects'
}



resource profiles_lc_frontdoor_name_ConsultingRedirects_Angular 'Microsoft.Cdn/profiles/rulesets/rules@2021-06-01' = {
  parent: profiles_lc_frontdoor_name_ConsultingRedirects
  name: 'Angular'
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
            'ssw/consulting/angular.aspx'
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
          customPath: '/'
        }
      }
    ]
    matchProcessingBehavior: 'Stop'
  }
  dependsOn: [
    //profiles_lc_frontdoor_name_resource
  ]
}
