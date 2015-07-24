#Create the developer network and associated resource group
New-AzureResourceGroup -Name "az-dev-net" -Location "North Europe" `
 -TemplateFile "C:\Projects\GitHub\azure-devtest-samples\01-az-dev-net\azuredeploy.json" `
 -TemplateParameterFile "C:\Projects\GitHub\azure-devtest-samples\01-az-dev-net\azuredeploy.parameters.json" `
 -Verbose -Force

#Create a workstation to remote in and test stuff
$secPwd = ConvertTo-SecureString "Corp123!" -AsPlainText -Force
New-AzureResourceGroup -Name "az-wrk-stn" -Location "North Europe" `
-TemplateFile "c:\projects\GitHub\azure-devtest-samples\02-az-wrk-stn\azuredeploy.json" `
-TemplateParameterFile "c:\projects\GitHub\azure-devtest-samples\02-az-wrk-stn\azuredeploy.parameters.json" `
 -devVNETResourceGroup "az-dev-net" -devVNETVirtualNetworkName "az-dev-net" `
-appSubnetName "subnetFrontEnd" -adminPassword $secPwd  `
-Verbose -Force

#Create the dns server resource group
$secPwd = ConvertTo-SecureString "Corp123!" -AsPlainText -Force
New-AzureResourceGroup -Name "az-dns-grp" -Location "North Europe" `
 -TemplateFile "c:\projects\GitHub\azure-devtest-samples\03-az-dns-srv\azuredeploy.json" `
 -TemplateParameterFile "c:\projects\GitHub\azure-devtest-samples\03-az-dns-srv\azuredeploy.parameters.json" `
 -adminPassword $secPwd  `
 -devVNETResourceGroup "az-dev-net" -devVNETVirtualNetworkName "az-dev-net" `
 -Verbose -Force


#Create the management resource group
New-AzureResourceGroup -Name "az-mgt-grp" -Location "North Europe" `
 -TemplateFile "c:\projects\GitHub\azure-devtest-samples\04-az-mgmt-grp\azuredeploy.json" `
 -TemplateParameterFile "c:\projects\GitHub\azure-devtest-samples\04-az-mgmt-grp\azuredeploy.parameters.json" `
  -devVNETResourceGroup "az-dev-net" -devVNETVirtualNetworkName "az-dev-net" `
 -Verbose -Force

#Creat the developer environment resource group
$secPwd = ConvertTo-SecureString "Corp123!" -AsPlainText -Force
New-AzureResourceGroup -Name "az-dev-101" -Location "North Europe" `
-TemplateFile "c:\projects\GitHub\azure-devtest-samples\05-az-dev-xxx\azuredeploy.json" `
-TemplateParameterFile "c:\projects\GitHub\azure-devtest-samples\05-az-dev-xxx\azuredeploy.parameters.json" `
-appSubnetName "subnetdev101"  `
-devVNETResourceGroup "az-dev-net" -devVNETVirtualNetworkName "az-dev-net" `
-adminPassword $secPwd -sizeOfDiskInGB 40 `
-Verbose -Force
