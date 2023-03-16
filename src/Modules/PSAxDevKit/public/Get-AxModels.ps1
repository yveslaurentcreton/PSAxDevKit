function Get-AxModels {
    param (
        [string]$EnvironmentName
    )

    function Get-AxModelDisplayNames {
        param (
            [string]$DescriptorFolderPath,
            [string]$PackageName
        )

        $modelXmlFiles = Get-ChildItem -Path $DescriptorFolderPath -Filter "*.xml"
        $resultList = @()

        foreach ($modelXmlFile in $modelXmlFiles) {
            $modelMetadata = [xml](Get-Content -Path $modelXmlFile.FullName)
            $modelDisplayName = $modelMetadata.AxModelInfo.DisplayName
            $result = New-Object -TypeName PSObject -Property @{
                Name        = $modelDisplayName
                PackageName = $PackageName
            }
            $resultList += $result
        }

        return $resultList
    }

    if (-not $EnvironmentName) {
        $EnvironmentName = (Get-CurrentAxEnvironment).Name
    }

    $packages = Get-AxPackages -EnvironmentName $EnvironmentName
    $modelList = @()

    foreach ($package in $packages) {
        $descriptorFolderPath = Join-Path -Path $package.Folder -ChildPath "Descriptor"
        $models = Get-AxModelDisplayNames -DescriptorFolderPath $descriptorFolderPath -PackageName $package.Name
        $modelList += $models
    }

    $modelList
}
