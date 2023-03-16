function Get-AxPackages {
    param (
        [string]$EnvironmentName
    )

    if (-not $EnvironmentName) {
        $EnvironmentName = (Get-CurrentAxEnvironment).Name
    }

    $environment = Get-AxEnvironments | Where-Object { $_.Name -eq $EnvironmentName }

    if (-not $environment) {
        throw "Environment '$EnvironmentName' not found."
    }

    $metadataFolderPath = $environment.Folder
    $packageFolders = Get-ChildItem -Path $metadataFolderPath -Directory | Where-Object { Test-Path -Path (Join-Path -Path $_.FullName -ChildPath "Descriptor") }

    foreach ($packageFolder in $packageFolders) {
        New-Object -TypeName PSObject -Property @{
            Name   = $packageFolder.Name
            Folder = $packageFolder.FullName
        }
    }
}
