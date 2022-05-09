param profiles_lc_frontdoor_name string = 'lc-frontdoor'

resource profiles_lc_frontdoor_name_resource 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: profiles_lc_frontdoor_name
  location: 'Global'
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
  //kind: 'frontdoor'
  properties: {
    originResponseTimeoutSeconds: 60
  }
}

resource profiles_lc_frontdoor_name_lcfrontdoorendpoint 'Microsoft.Cdn/profiles/afdendpoints@2021-06-01' = {
  parent: profiles_lc_frontdoor_name_resource
  name: 'lcfrontdoorendpoint'
  location: 'Global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource profiles_lc_frontdoor_name_default_origin_group 'Microsoft.Cdn/profiles/origingroups@2021-06-01' = {
  parent: profiles_lc_frontdoor_name_resource
  name: 'default-origin-group'
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'HEAD'
      probeProtocol: 'Http'
      probeIntervalInSeconds: 100
    }
    sessionAffinityState: 'Disabled'
  }
}

resource profiles_lc_frontdoor_name_WebAppOriginGroup 'Microsoft.Cdn/profiles/origingroups@2021-06-01' = {
  parent: profiles_lc_frontdoor_name_resource
  name: 'WebAppOriginGroup'
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }
    healthProbeSettings: {
      probePath: '/ssw'
      probeRequestType: 'HEAD'
      probeProtocol: 'Http'
      probeIntervalInSeconds: 100
    }
    sessionAffinityState: 'Disabled'
  }
}

resource profiles_lc_frontdoor_name_ConsultingRedirects 'Microsoft.Cdn/profiles/rulesets@2021-06-01' = {
  parent: profiles_lc_frontdoor_name_resource
  name: 'ConsultingRedirects'
}

resource profiles_lc_frontdoor_name_default_origin_group_default_origin 'Microsoft.Cdn/profiles/origingroups/origins@2021-06-01' = {
  parent: profiles_lc_frontdoor_name_default_origin_group
  name: 'default-origin'
  properties: {
    hostName: 'staticstorage1.z26.web.{environment().suffixes.storage}'
    //hostName: 'staticstorage1.z26.web.core.windows.net'
    httpPort: 80
    httpsPort: 443
    originHostHeader: 'staticstorage1.z26.web.{environment().suffixes.storage}'
    //originHostHeader: 'staticstorage1.z26.web.core.windows.net'
    priority: 1
    weight: 1000
    enabledState: 'Enabled'
    enforceCertificateNameCheck: true
  }
  dependsOn: [
    //profiles_lc_frontdoor_name_resource
  ]
}

resource profiles_lc_frontdoor_name_WebAppOriginGroup_WebAppOrigin 'Microsoft.Cdn/profiles/origingroups/origins@2021-06-01' = {
  parent: profiles_lc_frontdoor_name_WebAppOriginGroup
  name: 'WebAppOrigin'
  properties: {
    hostName: 'lc-ssw-webformsapp.azurewebsites.net'
    httpPort: 80
    httpsPort: 443
    originHostHeader: 'lc-ssw-webformsapp.azurewebsites.net'
    priority: 1
    weight: 1000
    enabledState: 'Enabled'
    enforceCertificateNameCheck: true
  }
  dependsOn: [
    //profiles_lc_frontdoor_name_resource
  ]
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

resource profiles_lc_frontdoor_name_lcfrontdoorendpoint_default_route 'Microsoft.Cdn/profiles/afdendpoints/routes@2021-06-01' = {
  parent: profiles_lc_frontdoor_name_lcfrontdoorendpoint
  name: 'default-route'
  properties: {
    cacheConfiguration: {
      compressionSettings: {
        isCompressionEnabled: true
        contentTypesToCompress: [
          'application/eot'
          'application/font'
          'application/font-sfnt'
          'application/javascript'
          'application/json'
          'application/opentype'
          'application/otf'
          'application/pkcs7-mime'
          'application/truetype'
          'application/ttf'
          'application/vnd.ms-fontobject'
          'application/xhtml+xml'
          'application/xml'
          'application/xml+rss'
          'application/x-font-opentype'
          'application/x-font-truetype'
          'application/x-font-ttf'
          'application/x-httpd-cgi'
          'application/x-javascript'
          'application/x-mpegurl'
          'application/x-opentype'
          'application/x-otf'
          'application/x-perl'
          'application/x-ttf'
          'font/eot'
          'font/ttf'
          'font/otf'
          'font/opentype'
          'image/svg+xml'
          'text/css'
          'text/csv'
          'text/html'
          'text/javascript'
          'text/js'
          'text/plain'
          'text/richtext'
          'text/tab-separated-values'
          'text/xml'
          'text/x-script'
          'text/x-component'
          'text/x-java-source'
        ]
      }
      queryStringCachingBehavior: 'IgnoreQueryString'
    }
    customDomains: []
    originGroup: {
      id: profiles_lc_frontdoor_name_default_origin_group.id
    }
    ruleSets: []
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'MatchRequest'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
    enabledState: 'Enabled'
  }
  dependsOn: [
    //profiles_lc_frontdoor_name_resource
  ]
}

resource profiles_lc_frontdoor_name_lcfrontdoorendpoint_WebAppRoutes 'Microsoft.Cdn/profiles/afdendpoints/routes@2021-06-01' = {
  parent: profiles_lc_frontdoor_name_lcfrontdoorendpoint
  name: 'WebAppRoutes'
  properties: {
    customDomains: []
    originGroup: {
      id: profiles_lc_frontdoor_name_WebAppOriginGroup.id
    }
    originPath: '/ssw'
    ruleSets: [
      {
        id: profiles_lc_frontdoor_name_ConsultingRedirects.id
      }
    ]
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/ssw'
      '/ssw/*'
    ]
    forwardingProtocol: 'MatchRequest'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
    enabledState: 'Enabled'
  }
  dependsOn: [
    //profiles_lc_frontdoor_name_resource
  ]
}
