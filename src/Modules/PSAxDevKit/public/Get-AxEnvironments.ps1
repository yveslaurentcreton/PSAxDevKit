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
