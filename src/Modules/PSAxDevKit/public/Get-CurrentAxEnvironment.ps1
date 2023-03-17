<#
    .SYNOPSIS
    Retrieves the current Ax environment.

    .DESCRIPTION
    The Get-CurrentAxEnvironment function reads the web.config file of the AOSService,
    extracts the metadata directory path, and compares it with the available Ax environments.
    It then returns the current Ax environment object that matches the metadata directory path.

    .EXAMPLE
    Get-CurrentAxEnvironment
    This example retrieves the current Ax environment object.

    .OUTPUTS
    PSObject. The function returns an object containing the current Ax environment's name and folder path.

    .NOTES
    This function assumes that the AOSService web.config file is located at the specified path and is accessible.
#>
function Get-CurrentAxEnvironment {
    $webConfigPath = "C:\AOSService\webroot\web.config"
    [xml]$webConfig = Get-Content -Path $webConfigPath
    $metadataDirectory = $webConfig.configuration.appSettings.add |
                         Where-Object { $_.key -eq "Aos.MetadataDirectory" } |
                         Select-Object -ExpandProperty value

    $environments = Get-AxEnvironments
    $currentEnvironment = $environments | Where-Object Folder -eq $metadataDirectory

    return $currentEnvironment
}
