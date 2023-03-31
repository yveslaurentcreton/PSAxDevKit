<#
    .SYNOPSIS
    Syncs one or more CRM virtual entities.

    .DESCRIPTION
    The Sync-CrmVirtualEntity function refreshes one or more CRM virtual entities by invoking the CRM API.

    .PARAMETER CrmUrl
    The base URL of the CRM instance.

    .PARAMETER TenantId
    The Azure Active Directory tenant ID.

    .PARAMETER ClientId
    The Azure Active Directory application (client) ID.

    .PARAMETER ClientSecret
    The Azure Active Directory application (client) secret.

    .PARAMETER VirtualEntity
    A single virtual entity name to refresh.

    .PARAMETER VirtualEntities
    An array of virtual entity names to refresh.

    .EXAMPLE
    Sync-CrmVirtualEntity -CrmUrl "https://your-crm-url" -TenantId "your-tenant-id" -ClientId "your-client-id" -ClientSecret "your-client-secret" -VirtualEntity "VirtualEntity1"
#>
function Sync-CrmVirtualEntity {
    param (
        [string]$CrmUrl,
        [string]$TenantId,
        [string]$ClientId,
        [string]$ClientSecret,
        [string]$VirtualEntity,
        [string[]]$VirtualEntities,

        [Parameter(Mandatory=$true, ParameterSetName='ByEntity')]
        [ValidateScript({
            if (-not $_ -and -not $VirtualEntities) {
                throw "You must provide either 'VirtualEntity' or 'VirtualEntities' parameter."
            }
            return $true
        })]$Validation
    )

    $crmApiUrl = "$CrmUrl/api/data/v9.2"

    # Acquire an access token
    $tokenUrl = "https://login.windows.net/$TenantId/oauth2/token"
    $tokenRequestBody = @{
        grant_type    = "client_credentials"
        client_id     = $ClientId
        client_secret = $ClientSecret
        resource      = $CrmUrl
    }

    $tokenResponse = Invoke-RestMethod -Uri $tokenUrl -Method Post -ContentType "application/x-www-form-urlencoded" -Body $tokenRequestBody
    $accessToken = $tokenResponse.access_token

    if ($VirtualEntity) {
        $VirtualEntities = @($VirtualEntity)
    }

    # Iterate through the virtual entities and refresh each one
    foreach ($virtualEntity in $VirtualEntities) {
        $refreshApiUrl = "$crmApiUrl/mserp_financeandoperationsentities?`$filter=mserp_physicalname%20eq%20'$virtualEntity'"
        $headers = @{
            Authorization = "Bearer $accessToken"
        }
        $body = @{
            mserp_refresh = $true
        }

        try {
            Invoke-RestMethod -Method Patch -Uri $refreshApiUrl  -Headers $Headers -Body $body
            Write-Host "Virtual entity '$virtualEntity' refreshed successfully."
        } catch {
            Write-Host "Error refreshing virtual entity '$virtualEntity':"
            Write-Host $_.Exception.Response.StatusCode.Value__
            Write-Host $_.Exception.Message
        }
    }
}
