function Restore-AxNuGetPackages {
    param (
        [string]$EnvironmentName
    )

    function Get-CompatibleDlls {
        param(
            [string]$nugetFolderPath,
            [string]$frameworkVersion
        )

        $compatibleDlls = Get-ChildItem -Path $nugetFolderPath -Recurse -Include "*.dll" |
        Where-Object { $_.FullName -match "lib\\$frameworkVersion" }

        return $compatibleDlls
    }

    function Copy-Dlls {
        param(
            [string]$sourcePath,
            [string]$destinationPath
        )

        Copy-Item -Path $sourcePath -Destination $destinationPath -Force
    }

    function Create-AxReference {
        param(
            [string]$dllPath,
            [string]$axReferenceFolderPath
        )

        $assembly = [Reflection.Assembly]::LoadFile($dllPath)

        $axReference = @"
<?xml version="1.0" encoding="utf-8"?>
<AxReference xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
    <Name>$($assembly.GetName().Name)</Name>
    <AssemblyName>$($assembly.GetName().Name)</AssemblyName>
    <AssemblyDisplayName>$($assembly.FullName)</AssemblyDisplayName>
    <PublicKeyToken>$($assembly.GetName().GetPublicKeyToken() -join "")</PublicKeyToken>
    <Version>$($assembly.GetName().Version.ToString())</Version>
</AxReference>
"@

        $axReferencePath = Join-Path -Path $axReferenceFolderPath -ChildPath "$($assembly.GetName().Name).xml"
        Set-Content -Path $axReferencePath -Value $axReference
    }

    function Install-PackagesAndCreateAxReferences {
        param(
            [string]$packagesConfigPath,
            [string]$packageFolder,
            [string]$nugetConfigPath
        )

        $folderPath = Split-Path -Parent $packagesConfigPath
        $nugetFolderPath = Join-Path -Path $folderPath -ChildPath "packages"
        $frameworkVersion = "netstandard2.0"
        $axReferenceFolderPath = Join-Path -Path $packageFolder -ChildPath "AxReference"

        # Install NuGet packages
        Invoke-Expression -Command "nuget restore $packagesConfigPath -PackagesDirectory $nugetFolderPath -ConfigFile $nugetConfigPath"

        # Get package folders
        $packageFolders = Get-ChildItem -Path $nugetFolderPath -Directory

        foreach ($packageFolder in $packageFolders) {
            # Get compatible DLLs
            $compatibleDlls = Get-CompatibleDlls -nugetFolderPath $packageFolder.FullName -frameworkVersion $frameworkVersion

            # If not found, use net472 as fallback
            if ($compatibleDlls.Count -eq 0) {
                $frameworkVersion = "net472"
                $compatibleDlls = Get-CompatibleDlls -nugetFolderPath $packageFolder.FullName -frameworkVersion $frameworkVersion
            }

            # Copy DLLs and create AxReference files
            foreach ($dll in $compatibleDlls) {
                $destinationPath = Join-Path -Path $folderPath -ChildPath $dll.Name
                Copy-Dlls -sourcePath $dll.FullName -destinationPath $destinationPath
                Create-AxReference -dllPath $destinationPath -axReferenceFolderPath $axReferenceFolderPath
            }
        }
    }

    if (-not $EnvironmentName) {
        $EnvironmentName = (Get-CurrentAxEnvironment).Name
    }

    $packages = Get-AxPackages -EnvironmentName $EnvironmentName
    $nugetConfigPath = Join-Path -Path $axEnvironment.Folder -ChildPath "nuget.config"

    # Loop over all packages in the environment
    foreach ($package in $packages) {
        $packagesConfigPath = Join-Path -Path $package.Folder -ChildPath "packages.config"
        if (Test-Path -Path $packagesConfigPath) {
            Install-PackagesAndCreateAxReferences -packagesConfigPath $packagesConfigPath -packageFolder $package.Folder -nugetConfigPath $nugetConfigPath
        }
    }
}