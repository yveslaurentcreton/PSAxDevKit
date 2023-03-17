function Restore-AxNuGetPackages {
    param (
        [string]$AxEnvironmentName = (Get-CurrentAxEnvironment).Name
    )

    function Install-PackagesAndCreateAxReferences {
        param(
            [string]$packagesConfigPath,
            [string]$packageFolder,
            [string]$nugetConfigPath
        )
    
        $folderPath = Split-Path -Parent $packagesConfigPath
        $nugetFolderPath = Join-Path -Path $folderPath -ChildPath "packages"
        $axReferenceFolder = Get-ChildItem "AxReference" -Path $packageFolder -Directory -Recurse
    
        # Read packages.config
        [xml]$packagesConfig = Get-Content -Path $packagesConfigPath
    
        # Install NuGet packages and their dependencies
        foreach ($package in $packagesConfig.packages.package) {
            $packageId = $package.id
            $packageVersion = $package.version
            $targetFramework = $package.targetFramework
            $packageNuGetFolderPath = Join-Path -Path $nugetFolderPath -ChildPath $packageId

            # Install NuGet packages
            Invoke-Expression -Command "nuget install $packageId -Version $packageVersion -Framework $targetFramework -OutputDirectory $packageNuGetFolderPath"

            # Get nuget package folders
            $nugetItemFolders = Get-ChildItem -Path $packageNuGetFolderPath -Directory
        
            foreach ($nugetItemFolder in $nugetItemFolders) {

                # Get compatible DLLs
                $compatibleDlls = Get-ChildItem -Path $nugetItemFolder.FullName -Recurse -Include "*.dll" | Where-Object { $_.FullName -match "lib\\$targetFramework" }
        
                # Copy DLLs and create AxReference files
                foreach ($dll in $compatibleDlls) {
                    $destinationPath = Join-Path -Path $folderPath -ChildPath $dll.Name
                    Copy-Item -Path $dll.FullName -Destination $destinationPath -Force
                    Add-AxReference -DllPath $destinationPath -AxReferenceFolder $axReferenceFolder.FullName
                }
            }
        }
    }    

    # Determine the environment and move to that folder
    $axEnvironment = Get-AxEnvironments | Where-Object { $_.Name -eq $AxEnvironmentName }
    if (-not $axEnvironment) {
        throw "Environment '$axEnvironment' not found."
    }
    Set-Location $axEnvironment.Folder

    # Loop over all packages in the environment and restore the packages
    $packages = Get-AxPackages -AxEnvironmentFolder $axEnvironment.Folder
    foreach ($package in $packages) {
        $packagesConfigPath = Join-Path -Path $package.Folder -ChildPath "bin/packages.config"
        if (Test-Path -Path $packagesConfigPath) {
            Install-PackagesAndCreateAxReferences -packagesConfigPath $packagesConfigPath -packageFolder $package.Folder
        }
    }
}