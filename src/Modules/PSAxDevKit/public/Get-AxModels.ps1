function Get-AxModels {
    param (
        [string]$AxEnvironmentFolder = (Get-CurrentAxEnvironment).Folder
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

    $packages = Get-AxPackages -AxEnvironmentFolder $AxEnvironmentFolder
    $modelList = @()

    foreach ($package in $packages) {
        $descriptorFolderPath = Join-Path -Path $package.Folder -ChildPath "Descriptor"
        $models = Get-AxModelDisplayNames -DescriptorFolderPath $descriptorFolderPath -PackageName $package.Name
        $modelList += $models
    }

    $modelList
}
