params
(
    [parameter(Mandatory = $true)] [string] $databricksWorkspaceResourceId,
    [parameter(Mandatory = $true)] [string] $databricksWorkspaceUrl,
    [parameter(Mandatory = $false)] [int] $tokenLifeTimeSeconds = 300

)

$azureDatabricksPrincipalId = 'bc01497f-fd50-460d-a72c-6dc6ef344c66'

$headers = @{}
$headers["Authorization"] = "Bearer $((az account get-access-token --resource $azureDatabricksPrincipalId | ConvertFrom-Json).accessToken)"
$headers["X-Databricks-Azure-SP-Management-Token"] = "$((az account get-access-token --resource https://management.core.windows.net/ | ConvertFrom-Json).accessToken)"
$headers["X-Databricks-Azure-Workspace-Resource-Id"] = $databricksWorkspaceResourceId

$json = @{}
$json["lifetime_seconds"] = $tokenLifeTimeSeconds

$req = Invoke-WebRequest -Uri "https://$databricksWorkspaceUrl/api/2.0/token/create" -Method Post -Headers $headers -Body ($json | ConvertTo-Json) -ContentType "application/json"
$bearerToken = ($req.Content | ConvertFrom-Json).token_value

return $bearerToken