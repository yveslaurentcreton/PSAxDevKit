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