Get-AzureVM | Format-Table -Property Name, @{Label = "vmSize"; Expression = {$_.HardwareProfileze}}
Get-AzureVM | Stop-AzureVM -Force -Verbose
Get-AzureVM | Format-Table -Property Name, ProvisioningState
