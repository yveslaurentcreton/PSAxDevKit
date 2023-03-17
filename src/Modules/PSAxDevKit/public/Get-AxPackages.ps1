<#
    .SYNOPSIS
    Retrieves available Ax packages for a given Ax environment folder.

    .DESCRIPTION
    The Get-AxPackages function searches for Ax packages within the specified
    Ax environment folder (or the current environment folder if not specified)
    and returns a list of packages found. Each package is represented by a custom
    object containing the package name and the package folder path.

    .PARAMETER AxEnvironmentFolder
    Specifies the folder path for the Ax environment to search for packages.
    If not specified, the function will use the current Ax environment folder.

    .EXAMPLE
    $packages = Get-AxPackages
    This example retrieves a list of available Ax packages for the current Ax environment
    and stores the result in the $packages variable.

    .EXAMPLE
    $packages = Get-AxPackages -AxEnvironmentFolder "C:\AOSService\MyEnvironment"
    This example retrieves a list of available Ax packages for the specified Ax environment
    folder and stores the result in the $packages variable.

    .OUTPUTS
    PSObject
    This function returns an array of PSObjects with two properties: Name (the package name)
    and Folder (the package folder path).

    .NOTES
    This function assumes that Ax packages are located within the specified Ax environment folder
    and have a Descriptor subfolder.
#>
function Get-AxPackages {
    param (
        [string]$AxEnvironmentFolder = (Get-CurrentAxEnvironment).AxEnvironmentFolder
    )

    # Search for package folders
    $packageFolders = Get-ChildItem -Path $AxEnvironmentFolder -Directory | Where-Object { Test-Path -Path (Join-Path -Path $_.FullName -ChildPath "Descriptor") }

    # Return the fetched information
    foreach ($packageFolder in $packageFolders) {
        New-Object -TypeName PSObject -Property @{
            Name   = $packageFolder.Name
            Folder = $packageFolder.FullName
        }
    }
}
