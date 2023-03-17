<#
    .SYNOPSIS
    Adds an Ax reference to a specified DLL in a given Ax reference folder.

    .DESCRIPTION
    The Add-AxReference function takes a DLL file path and an Ax reference folder,
    generates an Ax reference XML file based on the DLL's metadata, and saves the
    XML file in the specified Ax reference folder.

    .PARAMETER DllPath
    Specifies the path to the DLL file for which the Ax reference is to be created.

    .PARAMETER AxReferenceFolder
    Specifies the path to the folder where the Ax reference XML file should be saved.

    .EXAMPLE
    Add-AxReference -DllPath "C:\MyLibraries\MyLibrary.dll" -AxReferenceFolder "C:\MyAxReferences"
    This example creates an Ax reference XML file for the MyLibrary.dll in the specified Ax reference folder.

    .OUTPUTS
    None. The function does not return any output but creates an Ax reference XML file in the specified folder.

    .NOTES
    This function assumes that the DLL file and the Ax reference folder are valid and accessible.
#>
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