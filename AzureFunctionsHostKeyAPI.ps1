
Function Get-Function-Jwt {
    Param (
        [string] [Parameter(Mandatory = $true)] $resourceGroupName,
        [string] [Parameter(Mandatory = $true)] $functionAppName
    )

    $resourceType = "Microsoft.Web/sites/config"
    $resourceName = "$functionAppName/publishingcredentials"
    $publishingCredentials = Invoke-AzResourceAction -ResourceGroupName $resourceGroupName -ResourceType $resourceType -ResourceName $resourceName -Action list -ApiVersion 2015-08-01 -Force
    
    $accessToken = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $publishingCredentials.Properties.PublishingUserName, $publishingCredentials.Properties.PublishingPassword)))
    
    $jwt = Invoke-RestMethod -Uri "https://$functionAppName.scm.azurewebsites.net/api/functions/admin/token" -Headers @{Authorization = ("Basic {0}" -f $accessToken)} -Method GET
    
    return $jwt
}

Function Set-FunctionHostKey {
    Param (
        [string] [Parameter(Mandatory=$true)] $accessToken,
        [string] [Parameter(Mandatory=$false)] $keyName="default",
        [string] [Parameter(Mandatory = $true)] $functionAppName,
        [string] [Parameter(Mandatory = $true)] $keyValue
    )

$data = @{
    "name" = "$keyName"
    "value" = "$keyValue"
    } | ConvertTo-Json;
    
    $response=Invoke-RestMethod -Method PUT -Headers @{Authorization = ("Bearer {0}" -f $accessToken)} -ContentType "application/json" -Uri "https://$functionName.azurewebsites.net/admin/host/keys/$keyName" -body $data
    $response
}

Function Get-FunctionHostKey {
    Param (
        [string] [Parameter(Mandatory=$true)] $accessToken,
        [string] [Parameter(Mandatory=$false)] $keyName="default",
        [string] [Parameter(Mandatory = $true)] $functionAppName
    )


    
    $response=Invoke-RestMethod -Method GET -Headers @{Authorization = ("Bearer {0}" -f $accessToken)} -ContentType "application/json" -Uri "https://$functionName.azurewebsites.net/admin/host/keys/$keyName"
    $response.value
}



$functionName="ssdtestfun"
$resourceGroupName=$functionName
$keyVal="new key value"

$accessToken=Get-Function-Jwt -resourceGroupName $resourceGroupName -functionAppName $functionName
Set-FunctionHostKey -accessToken $accessToken -functionAppName $functionName -keyValue $keyVal
Get-FunctionHostKey -accessToken $accessToken -functionAppName $functionName