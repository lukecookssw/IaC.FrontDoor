param frontdoor_name string
param origin_name string
param hostname string
param health_probe_path string = '/'

resource frontdoor 'Microsoft.Cdn/profiles@2021-06-01' existing = {
  name: frontdoor_name
}

resource origin_group 'Microsoft.Cdn/profiles/origingroups@2021-06-01' = {
  parent: frontdoor
  name: '${origin_name}-Group'
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }
    healthProbeSettings: {
      probePath: health_probe_path
      probeRequestType: 'HEAD'
      probeProtocol: 'Http'
      probeIntervalInSeconds: 100
    }
    sessionAffinityState: 'Disabled'
  }
}

resource origin 'Microsoft.Cdn/profiles/origingroups/origins@2021-06-01' = {
  parent: origin_group
  name: origin_name
  properties: {
    hostName: hostname
    httpPort: 80
    httpsPort: 443
    originHostHeader: hostname
    priority: 1
    weight: 1000
    enabledState: 'Enabled'
    enforceCertificateNameCheck: true
  }
}

output origin_group_id string = origin_group.id
