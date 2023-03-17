<#
    .SYNOPSIS
    Retrieves information about a NuGet package.

    .DESCRIPTION
    The Get-NuGetInfo function uses the NuGet CLI to query the specified package ID and returns its name and latest version.
    If the PreRelease switch is provided, it will include pre-release versions in the search.

    .PARAMETER PackageId
    A string containing the NuGet package ID to query.

    .PARAMETER PreRelease
    A switch parameter that, when specified, includes pre-release versions in the search for the package.

    .EXAMPLE
    Get-NuGetInfo -PackageId "MyPackage"
    This example retrieves the NuGet package information for the package "MyPackage" and returns the latest stable version.

    .EXAMPLE
    Get-NuGetInfo -PackageId "MyPackage" -PreRelease
    This example retrieves the NuGet package information for the package "MyPackage" and returns the latest version, including pre-release versions if available.

    .OUTPUTS
    PSObject. The function returns an object containing the NuGet package's name and latest version.

    .NOTES
    This function requires the NuGet CLI to be installed and accessible in the system's PATH.
#>
function Get-NuGetInfo {
    param(
        [string]$PackageId,
        [switch]$PreRelease
    )

    $nugetArguments = "list $PackageId"
    if ($PreRelease) {
        $nugetArguments += " -PreRelease"
    }

    $nugetOutput = Invoke-Expression -Command "nuget $nugetArguments"
    $latestVersion = ($nugetOutput[-1] -split " ")[-1]
    $nuGetInfo = New-Object -TypeName PSObject -Property @{
        Name            = $PackageId
        LatestVersion   = $latestVersion
    }

    return $nuGetInfo
}