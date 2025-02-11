@description('Name of the alert')
@minLength(1)
param alertName string

@description('Description of alert')
param alertDescription string = 'Successful Connections'

@description('array of Azure resource Ids. For example - /subscriptions/00000000-0000-0000-0000-0000-00000000/resourceGroup/resource-group-name/Microsoft.compute/virtualMachines/vm-name')
@minLength(1)
param targetResourceId array

@description('Azure region in which target resources to be monitored are in (without spaces). For example: EastUS')
param targetResourceRegion string

@description('Resource type of target resources to be monitored.')
@minLength(1)
param targetResourceType string

@description('Specifies whether the alert is enabled')
param isEnabled bool = true

@description('Severity of alert {0,1,2,3,4}')
@allowed([
  0
  1
  2
  3
  4
])
param alertSeverity int = 4

@description('Operator comparing the current value with the threshold value.')
@allowed([
  'GreaterThan'
  'LessThan'
  'GreaterOrLessThan'
])
param operator string = 'LessThan'

@description('Tunes how \'noisy\' the Dynamic Thresholds alerts will be: \'High\' will result in more alerts while \'Low\' will result in fewer alerts.')
@allowed([
  'High'
  'Medium'
  'Low'
])
param alertSensitivity string = 'Low'

@description('The number of periods to check in the alert evaluation.')
param numberOfEvaluationPeriods int = 5

@description('The number of unhealthy periods to alert on (must be lower or equal to numberOfEvaluationPeriods).')
param minFailingPeriodsToAlert int = 5

@description('How the data that is collected should be combined over time.')
@allowed([
  'Average'
  'Minimum'
  'Maximum'
  'Total'
  'Count'
])
param timeAggregation string = 'Total'

@description('Period of time used to monitor alert activity based on the threshold. Must be between five minutes and one hour. ISO 8601 duration format.')
@allowed([
  'PT5M'
  'PT15M'
  'PT30M'
  'PT1H'
])
param windowSize string = 'PT5M'

@description('how often the metric alert is evaluated represented in ISO 8601 duration format')
@allowed([
  'PT1M'
  'PT5M'
  'PT15M'
  'PT30M'
  'PT1H'
])
param evaluationFrequency string = 'PT5M'

@description('"The current date and time using the utcNow function. Used for deployment name uniqueness')
param currentDateTimeUtcNow string = utcNow()

@description('The customer usage identifier used for telemetry purposes. The default value of False enables telemetry. The value of True disables telemetry.')
@allowed([
  'Yes'
  'No'
])
param telemetryOptOut string = 'No'

resource metricAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: alertName
  location: 'global'
  tags: {
    _deployed_by_amba: 'true'
  }
  properties: {
    description: alertDescription
    scopes: targetResourceId
    targetResourceType: targetResourceType
    targetResourceRegion: targetResourceRegion
    severity: alertSeverity
    enabled: isEnabled
    evaluationFrequency: evaluationFrequency
    windowSize: windowSize
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      allOf: [
        {
          criterionType: 'DynamicThresholdCriterion'
          name: '1st criterion'
          metricName: 'connection_successful'
          dimensions: []
          operator: operator
          alertSensitivity: alertSensitivity
          failingPeriods: {
            numberOfEvaluationPeriods: numberOfEvaluationPeriods
            minFailingPeriodsToAlert: minFailingPeriodsToAlert
          }
          timeAggregation: timeAggregation
        }
      ]
    }
  }
}

var ambaTelemetryPidName = 'pid-8bb7cf8a-bcf7-4264-abcb-703ace2fc84d-${uniqueString(resourceGroup().id, alertName, currentDateTimeUtcNow)}'
resource ambaTelemetryPid 'Microsoft.Resources/deployments@2023-07-01' =  if (telemetryOptOut == 'No') {
  name: ambaTelemetryPidName
  tags: {
    _deployed_by_amba: 'true'
  }
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}
