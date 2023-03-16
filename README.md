# PSAxDevKit

PowerShell module for Dynamics 365 Finance and Operations development tools.

## Description

PSAxDevKit is a PowerShell module that provides a set of development tools for Dynamics 365 Finance and Operations developers. This module simplifies various tasks, such as managing environments, installing NuGet packages, and working with AX packages.

## Installation

To install the PSAxDevKit module from the PowerShell Gallery, run the following command in your PowerShell session:

```powershell
Install-Module -Name PSAxDevKit
```

## Usage

After installing the PSAxDevKit module, you can use its functions in your PowerShell session. Below are some examples:

### Get-AxEnvironments

```powershell
Get-AxEnvironments
```

### Get-CurrentAxEnvironment

```powershell
Get-CurrentAxEnvironment
```

### Install-AxNuGetPackage

```powershell
Install-AxNuGetPackage -AxPackageName "MyPackage" -NuGetPackageId "MyNuGetPackage"
```

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests on the GitHub repository.

## License

This project is licensed under the MIT License. See the LICENSE file for details.