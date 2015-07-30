Get-AzureVM | Format-Table -Property Name, @{Label = "vmSize"; Expression = {$_.HardwareProfile.VirtualMachineSize}}
Get-AzureVM | Stop-AzureVM -Force -Verbose
Get-AzureVM | Format-Table -Property Name, ProvisioningState

Get-AzureNetworkInterface | Sort-Object -Property "Name" | Format-Table -Property ResourceGroupName, Name, @{Label = "PrivateIPAddress"; Expression={$_.IpConfigurations[0].PrivateIPAddress}}

((Get-AzureVM -ResourceGroupName "asos-devtest-poc-dns-grp" -Name "dnssrv-11").ResourceExtensionStatusList | Where-Object { $_.HandlerName -eq 'Microsoft.PowerShell.DSC' }).ExtensionSettingStatus.Status
