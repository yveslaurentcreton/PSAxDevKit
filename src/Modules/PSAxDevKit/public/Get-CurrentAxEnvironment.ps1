function Get-CurrentAxEnvironment {
    $webConfigPath = "C:\AOSService\webroot\web.config"
    [xml]$webConfig = Get-Content -Path $webConfigPath
    $metadataDirectory = $webConfig.configuration.appSettings.add |
                         Where-Object { $_.key -eq "Aos.MetadataDirectory" } |
                         Select-Object -ExpandProperty value

    $environments = Get-AxEnvironments
    $currentEnvironment = $environments | Where-Object Folder -eq $metadataDirectory

    return $currentEnvironment
}
