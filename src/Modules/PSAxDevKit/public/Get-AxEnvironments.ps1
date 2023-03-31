<#
    .SYNOPSIS
    Retrieves available Ax environments.

    .DESCRIPTION
    The Get-AxEnvironments function searches for Ax environments in the
    'C:\AOSService' directory and returns a list of environments found.
    Each environment is represented by a custom object containing the environment
    name and the folder path.

    .EXAMPLE
    $environments = Get-AxEnvironments
    This example retrieves a list of available Ax environments and stores the result in the $environments variable.

    .OUTPUTS
    PSObject
    This function returns an array of PSObjects with two properties: Name (the environment name) and Folder (the environment's folder path).

    .NOTES
    This function assumes that Ax environments are located in the 'C:\AOSService' directory.
#>
function Get-AxEnvironments {
    $rootPath = "C:\AOSService"
    $folders = Get-ChildItem -Path $rootPath -Directory

    $environments = @()
    foreach ($folder in $folders) {
        $configFilePath = Join-Path -Path $folder.FullName -ChildPath "bin\DynamicsDevConfig.xml"
        if (Test-Path -Path $configFilePath) {
            $envName = $folder.Name
            if ($envName -eq "PackagesLocalDirectory") {
                $envName = "Standard Ax"
            }
            $environments += New-Object -TypeName PSObject -Property @{
                Name    = $envName
                Folder  = $folder.FullName
            }
        }
    }
    return $environments
}
