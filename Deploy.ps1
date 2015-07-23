New-AzureResourceGroup -Name devVNET -Location "North Europe" `
 -TemplateFile "c:\projects\Azure\devVNET\azuredeploy.json" `
 -TemplateParameterFile "c:\projects\Azure\devVNET\azuredeploy.parameters.json" `
 -Verbose -Force

New-AzureResourceGroup -Name mgmt -Location "North Europe" `
 -TemplateFile "c:\projects\Azure\mgmt\azuredeploy.json" `Get
 -TemplateParameterFile "c:\projects\Azure\mgmt\azuredeploy.parameters.json" `
 -Verbose -Force

$secPwd = ConvertTo-SecureString "Corp123!" -AsPlainText -Force
New-AzureResourceGroup -Name "as-dev-101" -Location "North Europe" `
-TemplateFile "c:\projects\Azure\app\azuredeploy.json" `
-TemplateParameterFile "c:\projects\Azure\app\azuredeploy.parameters.json" `
-appSubnetName "subnetdev101" -storageName "asdev101" -vmName "asaz-devweb-101" `
-adminPassword $secPwd -sizeOfDiskInGB 40 `
-Verbose -Force  

New-AzureResourceGroup -Name app2 -Location "North Europe" `
 -TemplateFile "c:\projects\Azure\app\azuredeploy.json" `
 -TemplateParameterFile "c:\projects\Azure\app\azuredeploy.parameters.json" `
 -Verbose -Force -appSubnetName "subnet2"

New-AzureResourceGroup -Name app3 -Location "North Europe" `
 -TemplateFile "c:\projects\Azure\app\azuredeploy.json" `
 -TemplateParameterFile "c:\projects\Azure\app\azuredeploy.parameters.json" `
 -appSubnetName "subnet3" -Verbose -Force `

$secPwd = ConvertTo-SecureString "Corp123!" -AsPlainText -Force
 New-AzureResourceGroup -Name pctst04 -Location "North Europe" `
  -TemplateFile "c:\projects\Azure\pubip\azuredeploy.json" `
  -TemplateParameterFile "c:\projects\Azure\pubip\azuredeploy.parameters.json" `
  -Verbose -Force -adminPassword $secPwd

$secPwd = ConvertTo-SecureString "Corp123!" -AsPlainText -Force
New-AzureResourceGroup -Name pcqarmdemo -Location "North Europe" `
    -TemplateFile "c:\projects\Azure\vnettovnet\azuredeploy.json" `
    -TemplateParameterFile "c:\projects\Azure\vnettovnet\azuredeploy.parameters.json" `
    -Verbose -Force -adminPassword $secPwd -prefixparam pcqarmdemo
