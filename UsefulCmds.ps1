Get-AzureVM | Format-Table -Property Name, @{Label = "vmSize"; Expression = {$_.HardwareProfile.VirtualMachineSize}}
Get-AzureVM | Stop-AzureVM -Force -Verbose
Get-AzureVM | Format-Table -Property Name, ProvisioningState

Get-AzureNetworkInterface | Sort-Object -Property "Name" | Format-Table -Property ResourceGroupName, Name, @{Label = "PrivateIPAddress"; Expression={$_.IpConfigurations[0].PrivateIPAddress}}

((Get-AzureVM -ResourceGroupName "asos-devtest-poc-dns-grp" -Name "dnssrv-11").ResourceExtensionStatusList | Where-Object { $_.HandlerName -eq 'Microsoft.PowerShell.DSC' }).ExtensionSettingStatus.Status

$vmsList = @('av-01','chef-01','dev101sql-01','dev101utl-01', `
'dev101web-01','devdc-01','devdc-02','dnssrv-11', `
'dnssrv-21','es-01','es-02','fs-01','mon-01','mon-02', `
'prov-01','tst101apa-01','tst101apa-02', `
'tst101apb-01','tst101boweb01','tst101sqa-01', `
'tst101sqb-01','tst101utl-01','tst101web-01', `
'tst101web-02','wsus-01' )

$vmsToShutdown = @('dnssrv-11','dnssrv-21')


#Note: You will need to run this workflow in the 64 bit PowerShell which is available under c:\windows\system32\WindowsPowerShell
workflow ShutdownAzureVMs {
    param([string[]]$vmsList)
    $vms = Get-AzureVM
    Foreach -parallel ($vm in $vms)
    {
        Foreach ($vmName in $vmsList)
        {
            if ( $vmName -eq $vm.Name) {
                    (InlineScript { Write-Output "Shutting down... $Using:vmName"})
                    Stop-AzureVM -ResourceGroupName $vm.ResourceGroupName -Name $vmName  -Force -Verbose
                    #Write-Host "$vmName has been shut down"
            }
        }
    }
}

workflow StartAzureVMs {
    param([string[]]$vmsList)
    $vms = Get-AzureVM
    Foreach -parallel ($vm in $vms)
    {
        Foreach ($vmName in $vmsList)
        {
            if ( $vmName -eq $vm.Name) {
                    (InlineScript { Write-Output "Starting up... $Using:vmName"})
                    #Start-AzureVM -ResourceGroupName $vm.ResourceGroupName -Name $vmName -Verbose
                    #Write-Host "$vmName has been shut down"
            }
        }
    }
}
