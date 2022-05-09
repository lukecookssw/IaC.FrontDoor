param frontdoor_name string
param endpoint_name string
param origin_group_id string
param ruleset_id string
param origin_path string
param accepted_routes array


resource parent 'Microsoft.Cdn/profiles@2021-06-01' existing = {
  name: frontdoor_name
}

resource endpoint 'Microsoft.Cdn/profiles/afdendpoints@2021-06-01' existing = {
  parent: parent
  name: endpoint_name
}

resource routes 'Microsoft.Cdn/profiles/afdendpoints/routes@2021-06-01' = {
  parent: endpoint
  name: 'WebAppRoutes'
  properties: {
    customDomains: []
    originGroup: {
      id: origin_group_id
    }
    originPath: origin_path
    ruleSets: [
      {
        id: ruleset_id
      }
    ]
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: accepted_routes
    forwardingProtocol: 'MatchRequest'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
    enabledState: 'Enabled'
  }
}
