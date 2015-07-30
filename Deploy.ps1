$companyPrefix = "cust-devtest-poc"
$devVNETResourceGroup = $companyPrefix + '-dev-net'
$devVNETVirtualNetworkName = $devVNETResourceGroup
$location = 'North Europe'
$secPwd = ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force

#Create the developer network and associated resource group
New-AzureResourceGroup -Name $devVNETResourceGroup -Location $location `
 -TemplateFile ".\01-az-dev-net\azuredeploy.json" `
 -TemplateParameterFile ".\01-az-dev-net\azuredeploy.parameters.json" `
 -Verbose -Force

#Create a workstation to remote in and test stuff
$wrkStnResourceGroup = $companyPrefix + '-wrk-stn'
$wrkStnStorageAccountName = $wrkStnResourceGroup.Replace('-','')
New-AzureResourceGroup -Name $wrkStnResourceGroup -Location $location `
-TemplateFile ".\02-az-wrk-stn\azuredeploy.json" `
-TemplateParameterFile ".\02-az-wrk-stn\azuredeploy.parameters.json" `
-devVNETResourceGroup $devVNETResourceGroup `
-devVNETVirtualNetworkName $devVNETVirtualNetworkName `
-storageAccountNameFromTemplate $wrkStnStorageAccountName `
-appSubnetName "FrontEndSubnet"  `
-vmNamePrefix 'wrk-stn-0' -numberofVms 3 `
-adminPassword $secPwd  -Verbose -Force

#Create the dns server resource group
$dnsResourceGroup = $companyPrefix + '-dns-grp'
$dnsStorageAccountName = $dnsResourceGroup.Replace('-','')
New-AzureResourceGroup -Name $dnsResourceGroup -Location $location `
 -TemplateFile ".\03-az-dns-srv\azuredeploy.json" `
-TemplateParameterFile ".\03-az-dns-srv\azuredeploy.parameters.json" `
-devVNETResourceGroup $devVNETResourceGroup `
-devVNETVirtualNetworkName $devVNETVirtualNetworkName `
-storageAccountNameFromTemplate $dnsStorageAccountName `
-dnsServer01 "10.208.2.4" -dnsServer02 "10.208.2.5" `
-primarydnsVMNamePrefix "dnssrv-1" -numberofprimarydnsVms 1 `
-secondarydnsVMNamePrefix "dnssrv-2" -numberofsecondarydnsVms 1 `
-adminPassword $secPwd  -Verbose -Force

#Create the management resource group
$mgtResourceGroup = $companyPrefix + '-mgt-grp'
$mgtStorageAccountName = $mgtResourceGroup.Replace('-','')
New-AzureResourceGroup -Name $mgtResourceGroup -Location $location `
 -TemplateFile ".\04-az-mgt-grp\azuredeploy.json" `
 -TemplateParameterFile ".\04-az-mgt-grp\azuredeploy.parameters.json" `
  -devVNETResourceGroup $devVNETResourceGroup `
  -devVNETVirtualNetworkName $devVNETVirtualNetworkName `
  -storageAccountNameFromTemplate $mgtStorageAccountName `
  -dcVMNamePrefix "devdc-0" -numberofdcVms 2 `
  -fsVMNamePrefix "fs-0" -numberoffsVms 1 `
  -chefVMNamePrefix "chef-0" -numberofchefVms 1 `
  -esVMNamePrefix "es-0" -numberofesVms 2 `
  -monVMNamePrefix "mon-0" -numberofmonVms 2 `
  -wsusVMNamePrefix "wsus-0" -numberofwsusVms 1 `
  -provVMNamePrefix "prov-0" -numberofprovVms 1 `
  -avVMNamePrefix "av-0" -numberofavVms 1 `
  -sizeOfDiskInGB 40 `
 -adminPassword $secPwd  -Verbose -Force

#Create the developer test environment resource group
$devResourceGroup = $companyPrefix + '-dev-101'
$devStorageAccountName = $devResourceGroup.Replace('-','')
New-AzureResourceGroup -Name $devResourceGroup -Location $location `
-TemplateFile ".\05-az-dev-xxx\azuredeploy.json" `
-TemplateParameterFile ".\05-az-dev-xxx\azuredeploy.parameters.json" `
-devVNETResourceGroup $devVNETResourceGroup `
-devVNETVirtualNetworkName $devVNETVirtualNetworkName `
-storageAccountNameFromTemplate $devStorageAccountName `
-dnsServer01 "10.208.2.4" -dnsServer02 "10.208.2.5" `
-webVMNamePrefix "dev101web-0" -numberofWebVms 1 `
-sqlVMNamePrefix "dev101sql-0" -numberofSqlVms 1 `
-utilVMNamePrefix "dev101utl-0" -numberofUtilVms 1 `
-sizeOfDiskInGB 40 `
-adminPassword $secPwd  -Verbose -Force

#Create the functional test environment resource group
$tstResourceGroup = $companyPrefix + '-tst-101'
$tstStorageAccountName = $tstResourceGroup.Replace('-','')
New-AzureResourceGroup -Name $tstResourceGroup -Location $location `
-TemplateFile ".\06-az-tst-xxx\azuredeploy.json" `
-devVNETResourceGroup $devVNETResourceGroup `
-devVNETVirtualNetworkName $devVNETVirtualNetworkName `
-storageAccountNameFromTemplate $tstStorageAccountName `
-dnsServer01 "10.208.2.4" -dnsServer02 "10.208.2.5"  `
-webVMNamePrefix "tst101web-0" -numberofWebVms 2 `
-sqlAVMNamePrefix "tst101sqa-0" -numberofSqlAVms 1 `
-appAVMNamePrefix "tst101apa-0" -numberofAppAVms 2 `
-bowebVMNamePrefix "tst101boweb0" -numberofboWebVms 1 `
-sqlBVMNamePrefix "tst101sqb-0" -numberofSqlBVms 1 `
-appBVMNamePrefix "tst101apb-0" -numberofAppBVms 1 `
-utilVMNamePrefix "tst101utl-0" -numberofUtilVms 1 `
-sizeOfDiskInGB 40 `
-adminPassword $secPwd  -Verbose -Force
