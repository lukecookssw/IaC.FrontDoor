param frontdoor_name string
param frontdoor_endpoint_name string
param redirectsArray array

// var redirectsArray = [
//   {
//     name: 'angular'
//     requestPath: 'ssw/consulting/angular.aspx'
//     redirectPath: '/consulting/angular'
//   }
//   {
//     name: 'react'
//     requestPath: 'ssw/consulting/react.aspx'
//     redirectPath: '/consulting/react'
//   }
// ]

// create frontdoor
resource frontdoor 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: frontdoor_name
  location: 'Global'
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
  properties: {
    originResponseTimeoutSeconds: 60
  }
  tags: {
    CreatedBy: 'Warwick Leahy'
    owner: 'Piers Sinclair'
    Description: 'SSW web projects staging environment'
    AzDevOpsProjectName: 'SSW.Website + SSW.Rules + SSW.People + SSW.Website (legacy)'
  }
}

// set endpoint of frontdoor
resource frontdoor_endpoint 'Microsoft.Cdn/profiles/afdendpoints@2021-06-01' = {
  parent: frontdoor
  name: frontdoor_endpoint_name
  location: 'Global'
  properties: {
    enabledState: 'Enabled'
  }
}

// --- ORIGINS ---
// SSW Gatsby website
module static_site_origin_group './origins/origin-group.bicep' = {
  name: 'static-site-origin-group'
  params: {
    frontdoor_name: frontdoor_name
    origin_name: 'static-site-origin'
    hostname: 'staticstorage1.z26.web.${environment().suffixes.storage}'
  }
  dependsOn: [
    frontdoor
    frontdoor_endpoint
  ]
}

// App Service SSW website (Legacy)
module legacy_site_origin_group './origins/origin-group.bicep' = {
  name: 'legacy-site-origin-group'
  params: {
    frontdoor_name: frontdoor_name
    origin_name: 'legacy-site-origin'
    hostname: 'lc-ssw-webformsapp.azurewebsites.net'
    health_probe_path: '/ssw'
  }
  dependsOn: [
    frontdoor
    frontdoor_endpoint
  ]
}

// SSW People
// module people_origin_group './origins/origin-group.bicep' = {
//   name: 'ssw-people-staging'
//   params: {
//     frontdoor_name: frontdoor_name
//     origin_name: 'ssw-people-origin'
//     hostname: 'lc-ssw-webformsapp.azurewebsites.net'
//   }
//   dependsOn: [
//     frontdoor
//     frontdoor_endpoint
//   ]
// }

// --- RULESETS ---
// Consulting ruleset
module redirect_ruleset './rulesets/ruleset.bicep' = {
  name: 'redirect-ruleset'
  params: {
    frontdoor_name: frontdoor_name
    ruleset_name: 'RedirectsToStatic'
  }
  dependsOn: [
    frontdoor
  ]
}


// --- ROUTES ---
module static_site_routes './routes/routes-without-ruleset.bicep' = {
  name: 'static-site-routes'
  params: {
    frontdoor_name: frontdoor_name
    origin_group_id: static_site_origin_group.outputs.origin_group_id
    endpoint_name: frontdoor_endpoint_name
    origin_path: '/'
    route_name: 'gatsby-routes'
    accepted_routes: [
      '/*'
    ]
  }
}

module legacy_site_routes './routes/routes-with-ruleset.bicep' = {
  name: 'legacy-site-routes'
  params: {
    frontdoor_name: frontdoor_name
    origin_group_id: legacy_site_origin_group.outputs.origin_group_id
    endpoint_name: frontdoor_endpoint_name
    origin_path: '/ssw'
    ruleset_id: redirect_ruleset.outputs.out_ruleset_id
    route_name: 'legacy-routes'
    accepted_routes: [
      '/ssw'
      '/ssw/*'
    ]
  }
  dependsOn: [
    redirect_ruleset
  ]
}

// module people_site_routes './routes/routes-without-ruleset.bicep' = {
//   name: 'people-routes'
//   params: {
//     frontdoor_name: frontdoor_name
//     origin_group_id: people_origin_group.outputs.origin_group_id
//     endpoint_name: frontdoor_endpoint_name
//     origin_path: '/'
//     route_name: 'gatsby-routes'
//     accepted_routes: [
//       '/people'
//       '/people/*'
//     ]
//   }
// }

// --- REDIRECT RULES ---

module redirects './rulesets/rule-redirect.bicep' = [for (item, index) in redirectsArray: {
  name: item.name
  params: {
    frontdoor_name: frontdoor_name
    redirect_name: item.name
    order: (index +1)
    parent_ruleset_name: redirect_ruleset.outputs.out_ruleset_name
    url_path: item.requestPath
    redirect_path: item.redirectPath
  }
}]

// Consulting redirect rules
// module angular_redirect './ruleset-redirect.bicep' = {
//   name: 'angular'
//   params: {
//     frontdoor_name: frontdoor_name
//     redirect_name: 'Angular'
//     order: 0
//     parent_ruleset_name: consulting_redirect_ruleset.outputs.out_ruleset_name
//     url_path: 'ssw/consulting/angular.aspx'
//     redirect_path: '/consulting/angular'
//   }
//   dependsOn: [
//     consulting_redirect_ruleset
//   ]
// }
// module react_redirect './ruleset-redirect.bicep' = {
//   name: 'react'
//   params: {
//     frontdoor_name: frontdoor_name
//     redirect_name: 'React'
//     order: 1
//     parent_ruleset_name: consulting_redirect_ruleset.outputs.out_ruleset_name
//     url_path: 'ssw/consulting/react.aspx'
//     redirect_path: '/consulting/react'
//   }
//   dependsOn: [
//     consulting_redirect_ruleset
//   ]
// }


