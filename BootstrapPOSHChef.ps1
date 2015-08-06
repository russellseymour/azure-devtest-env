
<#

  .SYNOPSIS
    Installs, configures and executes POSHChef

  .DESCRIPTION
    Script to install and configure POSHChef before initially running it.
    The purpose of this script is to bootstrap a Windows Azure machine with POSHChef and
    its necessary modules

#>

[CmdletBinding()]
param (

  [string]
  # Name of the machine as it is known in Chef
  # if empty this will default to the computerbname
  $nodename = [String]::Empty,

  [String]
  # Runlist to be applied to the machine
  $runlist = [String]::Empty,

  [String]
  # String for the key
  $key,

  [Switch]
  # Specify if the supplied Key is a client key
  $client,

  [string]
  # Chef Server URL
  $chefserver
)

# Define the list of modules that need installing
$modules = @("PSGet", "Logging", "POSHChef")
Write-Output "Installing modules"

# One or more of the modules are not installed
foreach ($module in $modules) {

  $exists = Get-Module -ListAvailable -Name $module -ErrorAction SilentlyContinue

  # if exists is empty install the necessary module
  if ([String]::IsNullOrEmpty($exists)) {

    Write-Output "`t$module"

    # The installation method is different for PSGet than Logging and POSHChef
    if ($module -eq "PSGet") {
      $cmd = '(new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex'
      Invoke-Expression $cmd
    } else {

      # Set a hashtable of paths that should be used for each module
      $paths = @{
        "Logging" = "C:\Program Files\WindowsPowerShell\Modules"
        "POSHChef" = "C:\Windows\System32\WindowsPowerShell\v1.0\Modules"
      }

      # build up the command to install Logging and POSHChef
      $replacements = @(
        $module
        "https://www.myget.org/F/poshchef/api/v2"
        $paths.$module
      )
      $cmd = "Install-Module -NugetPackageId {0} -NugetSource {1} -Destination '{2}'" -f $replacements

      Write-Verbose ("{0} install command: {1}" -f $module, $cmd)
      Invoke-Expression $cmd
    }
  }
}

Write-Output "Configuring POSHChef"

# Ensure POSHChef is loaded
Import-Module Logging
Import-Module POSHChef

if (!(Test-Path -Path "C:\POSHChef\conf\client.psd1")) {

  # Determine the nodename
  if ([String]::IsNullOrEmpty($nodename)) {
    $nodename = $computername
  }

  # Build up the splat hashtable to pass to the Initialize-POSHChef command
  $splat = @{
    server = $chefserver
    nodename = $nodename.tolower()
  }

  # depending on whether the supplied key is a client add the approriate arguments
  if ($client) {
    $key_file = "{0}\client.pem" -f $env:TEMP
    $splat.client_key = $key_file

  } else {
    $key_file = "{0}\validator.pem" -f $env:TEMP
    $splat.validator = $key_file

  }
  Set-Content -Path $key_file -Value $key

  # Now call the initialzation of POSHChef
  Initialize-POSHChef @splat
}

Write-Output "Execute poshchef"

$splat = @{}
if (![String]::IsNullOrEmpty($runlist)) {
  $splat.runlist = $runlist
}

# Call the POSHChef Command
Invoke-POSHChef @splat
