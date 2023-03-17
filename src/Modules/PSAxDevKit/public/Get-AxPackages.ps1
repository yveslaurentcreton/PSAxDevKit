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
