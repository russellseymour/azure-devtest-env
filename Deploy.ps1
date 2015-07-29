$companyPrefix = "asos-devtest-poc"
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
-appSubnetName "FrontEndSubnet"  -vmName "wrk-stn-01" `
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
-adminPassword $secPwd  -Verbose -Force

#Create the management resource group
$mgtResourceGroup = $companyPrefix + '-mgt-grp'
$mgtStorageAccountName = $mgtStnResourceGroup.Replace('-','')
New-AzureResourceGroup -Name $mgtResourceGroup -Location $location `
 -TemplateFile ".\04-az-mgt-grp\azuredeploy.json" `
 -TemplateParameterFile ".\04-az-mgt-grp\azuredeploy.parameters.json" `
  -devVNETResourceGroup $devVNETResourceGroup `
  -devVNETVirtualNetworkName $devVNETVirtualNetworkName `
  -storageAccountNameFromTemplate $mgtStorageAccountName `
  -dcVMNamePrefix "devdc-0" -numberofdcVms 2 `
  -fsVMNamePrefix "fs-0" -numberoffsVms 1 `
 -adminPassword $secPwd  -Verbose -Force

#Create the developer test environment resource group
$devResourceGroup = $companyPrefix + '-dev-101'
$devStorageAccountName = $devStnResourceGroup.Replace('-','')
New-AzureResourceGroup -Name $devResourceGroup -Location $location `
-TemplateFile ".\05-az-dev-xxx\azuredeploy.json" `
-TemplateParameterFile ".\05-az-dev-xxx\azuredeploy.parameters.json" `
-devVNETResourceGroup $devVNETResourceGroup `
-devVNETVirtualNetworkName $devVNETVirtualNetworkName `
-dnsServer01 "10.208.2.4" -dnsServer02 "10.208.2.5" `
-webVMNamePrefix "dev101vmweb-0" -numberofwebVms 1 `
-sqlVMNamePrefix "dev101vmsql-0"  -numberofSqlVms 1 `
-utilVMNamePrefix "dev101vmsql-0"  -numberofUtilVms 1 `
-sizeOfDiskInGB 40 `
-adminPassword $secPwd  -Verbose -Force

#Create the functional test environment resource group
$secPwd = ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force
New-AzureResourceGroup -Name "az-tst-101" -Location $location `
-TemplateFile ".\06-az-tst-xxx\azuredeploy.json" `
-devVNETResourceGroup $devVNETResourceGroup `
-devVNETVirtualNetworkName $devVNETVirtualNetworkName `
-devVNETResourceGroup "az-dev-net" -devVNETVirtualNetworkName "az-dev-net" `
-dnsServer01 "10.208.2.4" -dnsServer02 "10.208.2.5" `
-webVMNamePrefix "tst101vmweb-0" -sqlAVMNamePrefix "tst101vmsqa-0" `
-appAVMNamePrefix "tst101vmapa-0"  `
-bowebVMNamePrefix "tst101vmboweb0" -sqlBVMNamePrefix "tst101vmsqb-0" `
-appBVMNamePrefix "tst101vmapb-0"  `
-sizeOfDiskInGB 40 `
-adminPassword $secPwd  -Verbose -Force
