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

#Creat the developer environment resource group
$secPwd = ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force
New-AzureResourceGroup -Name "az-dev-101" -Location "North Europe" `
-TemplateFile ".\05-az-dev-xxx\azuredeploy.json" `
-TemplateParameterFile ".\05-az-dev-xxx\azuredeploy.parameters.json" `
-devVNETResourceGroup "az-dev-net" -devVNETVirtualNetworkName "az-dev-net" `
-dnsServer01 "10.208.43.4" -dnsServer02 "10.208.43.5" `
-adminPassword $secPwd -sizeOfDiskInGB 40 `
-Verbose -Force
