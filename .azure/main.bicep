param frontdoor_name string = 'LC-AFD'
param frontdoor_endpoint_name string = 'LC-frontdoor-endpoint'
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
module static_site_origin_group './origin-group.bicep' = {
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
module legacy_site_origin_group './origin-group.bicep' = {
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

// --- RULESETS ---
// Consulting ruleset
module consulting_redirect_ruleset './ruleset.bicep' = {
  name: 'consulting-ruleset'
  params: {
    frontdoor_name: frontdoor_name
    ruleset_name: 'ConsultingRedirects'
  }
  dependsOn: [ 
    static_site_origin_group
  ]
}


// --- ROUTES ---
module static_site_routes './routes.bicep' = {
  name: 'static-site-routes'
  params: {
    frontdoor_name: frontdoor_name
    origin_group_id: static_site_origin_group.outputs.origin_group_id
    endpoint_name: frontdoor_endpoint_name
    origin_path: '/*'
    ruleset_id: consulting_redirect_ruleset.outputs.out_ruleset_id
    route_name: 'gatsby-routes'
    accepted_routes: [
      '/*'
    ]
  }
  dependsOn: [
    consulting_redirect_ruleset
  ]
}

module legacy_site_routes './routes.bicep' = {
  name: 'legacy-site-routes'
  params: {
    frontdoor_name: frontdoor_name
    origin_group_id: legacy_site_origin_group.outputs.origin_group_id
    endpoint_name: frontdoor_endpoint_name
    origin_path: '/'
    ruleset_id: consulting_redirect_ruleset.outputs.out_ruleset_id
    route_name: 'legacy-routes'
    accepted_routes: [
      '/ssw'
      '/ssw/*'
    ]
  }
  dependsOn: [
    consulting_redirect_ruleset
  ]
}

// --- RULES ---
// Consulting redirect rules
module angular_redirect './ruleset-redirect.bicep' = {
  name: 'angular'
  params: {
    frontdoor_name: frontdoor_name
    redirect_name: 'Angular'
    order: 0
    parent_ruleset_name: consulting_redirect_ruleset.outputs.out_ruleset_name
    url_path: 'ssw/consulting/angular.aspx'
    redirect_path: '/consulting/angular'
  }
  dependsOn: [
    consulting_redirect_ruleset
  ]
}
module react_redirect './ruleset-redirect.bicep' = {
  name: 'react'
  params: {
    frontdoor_name: frontdoor_name
    redirect_name: 'React'
    order: 1
    parent_ruleset_name: consulting_redirect_ruleset.outputs.out_ruleset_name
    url_path: 'ssw/consulting/react.aspx'
    redirect_path: '/consulting/react'
  }
  dependsOn: [
    consulting_redirect_ruleset
  ]
}


