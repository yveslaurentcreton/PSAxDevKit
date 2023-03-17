function Add-AxReference {
    param(
        [string]$DllPath,
        [string]$AxReferenceFolder
    )

    $assembly = [Reflection.Assembly]::LoadFile($dllPath)

    $axReference = @"
<?xml version="1.0" encoding="utf-8"?>
<AxReference xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
<Name>$($assembly.GetName().Name)</Name>
<AssemblyName>$($assembly.GetName().Name)</AssemblyName>
<AssemblyDisplayName>$($assembly.FullName)</AssemblyDisplayName>
<PublicKeyToken>$($assembly.GetName().GetPublicKeyToken() -join "")</PublicKeyToken>
<Version>$($assembly.GetName().Version.ToString())</Version>
</AxReference>
"@

    $axReferencePath = Join-Path -Path $AxReferenceFolder -ChildPath "$($assembly.GetName().Name).xml"
    Set-Content -Path $axReferencePath -Value $axReference
}