function Install-AxNuGetPackage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$AxPackageName,
        [Parameter(Mandatory = $true)]
        [string]$NuGetPackageId,
        [string]$PackageVersion = "",
        [switch]$Prerelease,
        [string]$Environment = (Get-CurrentAxEnvironment).Name
    )

    function Get-LatestPackageVersion {
        param(
            [string]$packageId,
            [switch]$prerelease
        )

        $nugetArguments = "list $packageId"
        if ($prerelease) {
            $nugetArguments += " -Prerelease"
        }

        $nugetOutput = nuget.exe $nugetArguments
        $latestVersion = ($nugetOutput -split " ")[-1]
        return $latestVersion
    }

    function Add-PackageToConfig {
        param(
            [string]$packagesConfigPath,
            [string]$packageId,
            [string]$packageVersion,
            [switch]$prerelease
        )
    
        if (-not $packageVersion) {
            $packageVersion = Get-LatestPackageVersion -packageId $packageId -prerelease:$prerelease
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
            $newPackage.SetAttribute("targetFramework", "net472")
            $packagesConfig.DocumentElement.AppendChild($newPackage)
            $packagesConfig.Save($packagesConfigPath)
        }
    }
    

    $axPackage = Get-AxPackages | Where-Object { $_.Name -eq $AxPackageName }
    if (-not $axPackage) {
        throw "Ax package '$AxPackageName' not found."
    }

    $binFolderPath = Join-Path -Path $axPackage.Folder -ChildPath "bin"
    $packagesConfigPath = Join-Path -Path $binFolderPath -ChildPath "packages.config"

    Add-PackageToConfig -packagesConfigPath $packagesConfigPath -packageId $NuGetPackageId -packageVersion $PackageVersion -prerelease:$Prerelease

    $axEnvironment = Get-AxEnvironments | Where-Object { $_.Name -eq $Environment }
    if (-not $axEnvironment) {
        throw "Environment '$Environment' not found."
    }

    $nugetConfigPath = Join-Path -Path $axEnvironment.Folder -ChildPath "nuget.config"
    Restore-AxNuGetPackages -AxPackageName $AxPackageName -NugetConfigPath $nugetConfigPath
}