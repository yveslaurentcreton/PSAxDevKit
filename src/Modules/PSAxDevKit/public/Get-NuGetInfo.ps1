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