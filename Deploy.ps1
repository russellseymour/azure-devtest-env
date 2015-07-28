#Create the developer network and associated resource group
New-AzureResourceGroup -Name "az-dev-net" -Location "North Europe" `
 -TemplateFile ".\01-az-dev-net\azuredeploy.json" `
 -TemplateParameterFile ".\01-az-dev-net\azuredeploy.parameters.json" `
 -Verbose -Force

#Create a workstation to remote in and test stuff
$secPwd = ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force
New-AzureResourceGroup -Name "az-wrk-stn" -Location "North Europe" `
-TemplateFile ".\02-az-wrk-stn\azuredeploy.json" `
-TemplateParameterFile ".\02-az-wrk-stn\azuredeploy.parameters.json" `
 -devVNETResourceGroup "az-dev-net" -devVNETVirtualNetworkName "az-dev-net" `
-appSubnetName "subnetFrontEnd" -adminPassword $secPwd  `
-Verbose -Force

#Create the dns server resource group
$secPwd = ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force
New-AzureResourceGroup -Name "az-dns-grp" -Location "North Europe" `
 -TemplateFile ".\03-az-dns-srv\azuredeploy.json" `
 -TemplateParameterFile ".\03-az-dns-srv\azuredeploy.parameters.json" `
 -adminPassword $secPwd  `
 -devVNETResourceGroup "az-dev-net" -devVNETVirtualNetworkName "az-dev-net" `
 -Verbose -Force

#Create the management resource group
New-AzureResourceGroup -Name "az-mgt-grp" -Location "North Europe" `
 -TemplateFile ".\04-az-mgt-grp\azuredeploy.json" `
 -TemplateParameterFile ".\04-az-mgt-grp\azuredeploy.parameters.json" `
  -devVNETResourceGroup "az-dev-net" -devVNETVirtualNetworkName "az-dev-net" `
 -Verbose -Force

#Create the developer test environment resource group
$secPwd = ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force
New-AzureResourceGroup -Name "az-dev-101" -Location "North Europe" `
-TemplateFile ".\05-az-dev-xxx\azuredeploy.json" `
-TemplateParameterFile ".\05-az-dev-xxx\azuredeploy.parameters.json" `
-devVNETResourceGroup "az-dev-net" -devVNETVirtualNetworkName "az-dev-net" `
-dnsServer01 "10.208.2.4" -dnsServer02 "10.208.2.5" `
-webVMNamePrefix "dev101vmweb-0" -sqlVMNamePrefix "dev101vmsql-0" `
-adminPassword $secPwd -sizeOfDiskInGB 40 `
-Verbose -Force

#Create the functional test environment resource group
$secPwd = ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force
New-AzureResourceGroup -Name "az-tst-101" -Location "North Europe" `
-TemplateFile ".\06-az-tst-xxx\azuredeploy.json" `
-TemplateParameterFile ".\06-az-tst-xxx\azuredeploy.parameters.json" `
-devVNETResourceGroup "az-dev-net" -devVNETVirtualNetworkName "az-dev-net" `
-dnsServer01 "10.208.2.4" -dnsServer02 "10.208.2.5" `
-webVMNamePrefix "tst101vmweb-0" -sqlAVMNamePrefix "tst101vmsqa-0" `
-appAVMNamePrefix "tst101vmapa-0"  `
-bowebVMNamePrefix "tst101vmboweb0" -sqlBVMNamePrefix "tst101vmsqb-0" `
-appBVMNamePrefix "tst101vmapb-0"  `
-adminPassword $secPwd -sizeOfDiskInGB 40 `
-Verbose -Force
