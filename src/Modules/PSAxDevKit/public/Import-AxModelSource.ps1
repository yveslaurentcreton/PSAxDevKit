<#
.SYNOPSIS
  Imports or replaces a single AX model source file.

.DESCRIPTION
  This script imports or replaces a specified '.axmodel' file using the ModelUtil.exe utility. It executes ModelUtil.exe with the necessary parameters and handles the output. The operation mode (import or replace) is determined by the Force parameter.

.PARAMETER AxModelSourceFileName
  The full path to the '.axmodel' file to be imported or replaced.

.PARAMETER AxEnvironmentFolder
  The folder of the AX environment. If not specified, it is obtained from Get-CurrentAxEnvironment.

.PARAMETER Force
  If specified, the script replaces the model source file. Otherwise, it imports the file.

.EXAMPLE
  PS> .\Import-AxModelSource.ps1 -AxModelSourceFileName "C:\Temp\MyModel.axmodel"

.EXAMPLE
  PS> .\Import-AxModelSource.ps1 -AxModelSourceFileName "C:\Temp\MyModel.axmodel" -Force

.NOTES
  Requires the ModelUtil.exe utility to be available in the AX environment folder.
  The Get-CurrentAxEnvironment function needs to be defined or available in the environment.
#>

function Import-AxModelSource {
  [CmdletBinding()]
  param (
      [Parameter(Mandatory=$true)]
      [string]$AxModelSourceFileName,

      [Parameter(Mandatory=$false)]
      [string]$AxEnvironmentFolder = (Get-CurrentAxEnvironment).Folder,

      [Parameter(Mandatory=$false)]
      [switch]$Force
  )

  # Validate the model source file path
  if (-not (Test-Path -Path $AxModelSourceFileName -PathType Leaf)) {
      Write-Error "Specified AX Model Source file does not exist: $AxModelSourceFileName"
      return
  }

  try {
      $modelUtilPath = "$AxEnvironmentFolder\bin\ModelUtil.exe"

      # Validate the existence of ModelUtil.exe
      if (-not (Test-Path -Path $modelUtilPath -PathType Leaf)) {
          Write-Error "ModelUtil.exe not found in the AX environment folder: $AxEnvironmentFolder"
          return
      }

      $operation = if ($Force) { "-replace" } else { "-import" }
      Write-Host "Operation: $operation on ModelSource '$AxModelSourceFileName'..."
      $pinfo = New-Object System.Diagnostics.ProcessStartInfo
      $pinfo.FileName = $modelUtilPath
      $pinfo.RedirectStandardError = $true
      $pinfo.RedirectStandardOutput = $true
      $pinfo.UseShellExecute = $false
      $pinfo.Arguments = " $operation -metadatastorepath=`"$AxEnvironmentFolder`" -file=`"$AxModelSourceFileName`" -Force"
      $p = New-Object System.Diagnostics.Process
      $p.StartInfo = $pinfo
      $p.Start() | Out-Null
      $p.WaitForExit()

      # Handling process output
      if ($p.ExitCode -eq 0) {
          Write-Host $p.StandardOutput.ReadToEnd()
      } else {
          Write-Host $p.StandardOutput.ReadToEnd()
          Write-Error "Model operation failed with exit code: $($p.ExitCode)"
      }
  } catch {
      Write-Error "An error occurred during the model operation: $_"
  }
}
