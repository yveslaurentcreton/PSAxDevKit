<#
    .SYNOPSIS
    Installs a NuGet package into an AX package and restores the package's dependencies.

    .DESCRIPTION
    The Install-AxNuGetPackage function installs a NuGet package into the specified AX package by updating the
    packages.config file and then running the Restore-AxNuGetPackages function to restore the package and its dependencies.

    .PARAMETER AxPackageName
    A string containing the AX package name where the NuGet package should be installed.

    .PARAMETER NuGetPackageId
    A string containing the NuGet package ID to install.

    .PARAMETER TargetFramework
    A string containing the target framework to use when installing the NuGet package.

    .PARAMETER PackageVersion
    A string containing the version of the NuGet package to install. If not specified, the latest available version
    will be installed.

    .PARAMETER Prerelease
    A switch parameter that, when specified, installs the latest pre-release version of the NuGet package if available.

    .PARAMETER AxEnvironmentName
    A string containing the name of the AX environment to use when installing the NuGet package. If not specified,
    the current AX environment will be used.

    .EXAMPLE
    Install-AxNuGetPackage -AxPackageName "MyAXPackage" -NuGetPackageId "MyNuGetPackage" -TargetFramework "net472"
    This example installs the latest version of the "MyNuGetPackage" NuGet package into the "MyAXPackage" AX package
    with the target framework "net472".

    .EXAMPLE
    Install-AxNuGetPackage -AxPackageName "MyAXPackage" -NuGetPackageId "MyNuGetPackage" -TargetFramework "net472" -PackageVersion "1.0.0"
    This example installs the specified version (1.0.0) of the "MyNuGetPackage" NuGet package into the "MyAXPackage" AX package
    with the target framework "net472".

    .EXAMPLE
    Install-AxNuGetPackage -AxPackageName "MyAXPackage" -NuGetPackageId "MyNuGetPackage" -TargetFramework "net472" -Prerelease
    This example installs the latest pre-release version of the "MyNuGetPackage" NuGet package into the "MyAXPackage" AX package
    with the target framework "net472".

    .OUTPUTS
    None.

    .NOTES
    This function requires the NuGet CLI to be installed and accessible in the system's PATH.
#>
function Install-AxNuGetPackage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$AxPackageName,
        [Parameter(Mandatory = $true)]
        [string]$NuGetPackageId,
        [string]$TargetFramework,
        [string]$PackageVersion = "",
        [switch]$Prerelease,
        [string]$AxEnvironmentName = (Get-CurrentAxEnvironment).Name
    )

    function Add-PackageToConfig {
        param(
            [string]$packagesConfigPath,
            [string]$packageId,
            [string]$targetFramework,
            [string]$packageVersion,
            [switch]$prerelease
        )
    
        if (-not $packageVersion) {
            $nuGetInfo = Get-NuGetInfo -PackageId $packageId -PreRelease:$prerelease
            $packageVersion = $nuGetInfo.LatestVersion
        }
    
        if (Test-Path -Path $packagesConfigPath) {
            [xml]$packagesConfig = Get-Content -Path $packagesConfigPath
        }
        else {
            $packagesConfig = New-Object -TypeName "System.Xml.XmlDocument"
            $xmlDeclaration = $packagesConfig.CreateXmlDeclaration("1.0", "utf-8", $null)
            $packagesConfig.AppendChild($xmlDeclaration)
            $packagesNode = $packagesConfig.CreateElement("packages")
            $packagesConfig.AppendChild($packagesNode)
            $packagesConfig.Save($packagesConfigPath)
            [xml]$packagesConfig = Get-Content -Path $packagesConfigPath
        }
    
        $packageExists = $packagesConfig.packages.package |
        Where-Object { $_.id -eq $packageId -and $_.version -eq $packageVersion }
    
        if (-not $packageExists) {
            $newPackage = $packagesConfig.CreateElement("package")
            $newPackage.SetAttribute("id", $packageId)
            $newPackage.SetAttribute("version", $packageVersion)
            $newPackage.SetAttribute("targetFramework", $targetFramework)
            $packagesConfig.DocumentElement.AppendChild($newPackage)
            $packagesConfig.Save($packagesConfigPath)
        }
    }

    # Determine the environment and move to that folder
    $axEnvironment = Get-AxEnvironments | Where-Object { $_.Name -eq $AxEnvironmentName }
    if (-not $axEnvironment) {
        throw "Environment '$axEnvironment' not found."
    }
    Set-Location $axEnvironment.Folder

    # Check if the package name is valid for the environment
    $axPackage = Get-AxPackages -AxEnvironmentFolder $axEnvironment.Folder | Where-Object { $_.Name -eq $AxPackageName }
    if (-not $axPackage) {
        throw "Ax package '$AxPackageName' not found."
    }

    # Determine parameters
    $binFolderPath = Join-Path -Path $axPackage.Folder -ChildPath "bin"
    $packagesConfigPath = Join-Path -Path $binFolderPath -ChildPath "packages.config"

    Add-PackageToConfig -packagesConfigPath $packagesConfigPath -packageId $NuGetPackageId -packageVersion $PackageVersion -prerelease:$Prerelease -targetFramework $TargetFramework
    Restore-AxNuGetPackages -AxPackageName $AxPackageName
}