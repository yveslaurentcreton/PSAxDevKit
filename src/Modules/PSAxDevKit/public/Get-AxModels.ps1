<#
    .SYNOPSIS
    Retrieves available Ax models for a given Ax environment folder.

    .DESCRIPTION
    The Get-AxModels function searches for Ax models within the specified
    Ax environment folder (or the current environment folder if not specified)
    and returns a list of models found. Each model is represented by a custom
    object containing the model display name and the package name.

    .PARAMETER AxEnvironmentFolder
    Specifies the folder path for the Ax environment to search for models.
    If not specified, the function will use the current Ax environment folder.

    .EXAMPLE
    $models = Get-AxModels
    This example retrieves a list of available Ax models for the current Ax environment
    and stores the result in the $models variable.

    .EXAMPLE
    $models = Get-AxModels -AxEnvironmentFolder "C:\AOSService\MyEnvironment"
    This example retrieves a list of available Ax models for the specified Ax environment
    folder and stores the result in the $models variable.

    .OUTPUTS
    PSObject
    This function returns an array of PSObjects with two properties: Name (the model display name)
    and PackageName (the package name to which the model belongs).

    .NOTES
    This function assumes that Ax models are located within the Descriptor folder
    of each Ax package in the specified Ax environment folder.
#>
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
