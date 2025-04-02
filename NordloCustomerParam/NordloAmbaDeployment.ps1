

az login --use-device-code

$location = "swedencentral" 
$pseudoRootManagementGroup = "MuovitechAB" 


az deployment mg create `
    --name "amba-Deployment-01" `
    --template-uri https://raw.githubusercontent.com/azure/azure-monitor-baseline-alerts/refs/heads/main/patterns/alz/alzArm.param.json `
    --location $location `
    --management-group-id $pseudoRootManagementGroup `
    --parameters "NordloAMBAFramework\NordloCustomerParam\alzArm.param_NordloCustomMuovitech_renew.json"


az logout