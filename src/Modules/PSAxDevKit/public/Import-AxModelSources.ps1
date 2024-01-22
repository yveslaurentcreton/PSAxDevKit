<#
.SYNOPSIS
  Imports or replaces multiple AX model source files from a specified zip file.

.DESCRIPTION
  This script extracts '.axmodel' files from a specified zip file and imports or replaces each of them into the AX environment. 
  It uses the Expand-7Zip cmdlet to extract the files and then calls a separate function to import or replace each model source file, based on the Force parameter.

.PARAMETER AxModelSourceZipFileName
  The full path to the AX model source zip file.

.PARAMETER Force
  If specified, the script replaces the model source files. Otherwise, it imports the files.

.EXAMPLE
  PS> .\Import-AxModelSources.ps1 -AxModelSourceZipFileName "C:\Path\To\ModelSource.zip"

.EXAMPLE
  PS> .\Import-AxModelSources.ps1 -AxModelSourceZipFileName "C:\Path\To\ModelSource.zip" -Force

.NOTES
  Requires the Expand-7Zip cmdlet for extraction and the Import-AxModelSource function with Force parameter support.
  The Get-CurrentAxEnvironment function needs to be defined or available in the environment.
#>

function Import-AxModelSources {
  [CmdletBinding()]
  param (
      [Parameter(Mandatory=$true)]
      [string]$AxModelSourceZipFileName,

      [Parameter(Mandatory=$false)]
      [switch]$Force
  )

  # Validate the zip file path
  if (-not (Test-Path -Path $AxModelSourceZipFileName -PathType Leaf)) {
      Write-Error "Specified AX Model Source Zip File does not exist: $AxModelSourceZipFileName"
      return
  }

  try {
      # Extracting AX model source zip file to a unique temporary folder
      $tempFolder = Join-Path -Path $env:TEMP -ChildPath ([System.IO.Path]::GetRandomFileName())
      Expand-7Zip -ArchiveFileName $AxModelSourceZipFileName -TargetPath $tempFolder -Verbose

      # Import or replace each .axmodel file found in the temp folder
      $axModelFiles = Get-ChildItem -Path $tempFolder -File -Filter "*.axmodel"
      foreach ($axModelSource in $axModelFiles) {
          Import-AxModelSource -AxModelSourceFileName $axModelSource.FullName -Force:$Force
      }
  } catch {
      Write-Error "An error occurred during the import process: $_"
  }
}
