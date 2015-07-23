$rgName = "devvnet4"
$location = "East US"

New-AzureResourceGroup -Name $rgName -Location $location `
 -TemplateFile "c:\projects\Azure\devVNET\azuredeploy.json" `
 -TemplateParameterFile "c:\projects\Azure\devVNET\azuredeploy.parameters.json" `
 -Verbose -Force

$vnetName = "devVNET"

${prefix} = $rgName

$vnetGatewayName = "${prefix}gw"

$vnetGatewayIpConfigName = "${prefix}gwip"

$vnetConnectionName = "${prefix}gwcon"

$vnetConnectionKey = "shared-key-value"

$publicGatewayVipName = "${prefix}gwvip"

$localGatewayName = "${prefix}gwcorp"

$localGatewayIP = "Public-IPv4-of-local-gateway"

$localNetworkPrefix = @( "10.1.1.0/20")

$tags = New-Object System.Collections.ArrayList
$tags.Add( @{ Name = "project"; Value = "demo" } )
$tags.Add( @{ Name = "costCenter"; Value = "0001" } )

$vnet = Get-AzureVirtualNetwork `
        -Name $vnetName `
        -ResourceGroupName $rgName

# Create a Public VIP for VNET Gateway

# Create a Public VIP for VNET Gateway

if (!(Test-AzureResource `
    -ResourceName $publicGatewayVipName `
    -ResourceType "Microsoft.Network/publicIPAddresses" `
    -ResourceGroupName $rgName)) {

    $publicGatewayVip = New-AzurePublicIpAddress `
        -Name $publicGatewayVipName `
        -ResourceGroupName $rgName `
        -Location $location `
        -AllocationMethod Dynamic `
        -DomainNameLabel $vNetGatewayName `
        -Tag $tags

} else {

    $publicGatewayVip = Get-AzurePublicIpAddress `
        -Name $publicGatewayVipName `
        -ResourceGroupName $rgName

}

# Attach VNET Gateway to VIP & Subnet

$vnetGatewayIpConfig = `
    New-AzureVirtualNetworkGatewayIpConfig `
        -Name $vnetGatewayIpConfigName `
        -PublicIpAddressId $publicGatewayVip.Id `
        -PrivateIpAddress "10.1.200.4" `
        -SubnetId $vnet.Subnets[4].Id

# Provision VNET Gateway

$vnetGateway = New-AzureVirtualNetworkGateway `
    -Name $vnetGatewayName `
    -ResourceGroupName $rgName `
    -Location $location `
    -GatewayType Vpn `
    -VpnType RouteBased `
    -IpConfigurations $vnetGatewayIpConfig `
    -Tag $tags

# Define Local Network

$localGateway = New-AzureLocalNetworkGateway `
    -Name $localGatewayName `
    -ResourceGroupName $rgName `
    -Location $location `
    -GatewayIpAddress $localGatewayIP `
    -AddressPrefix $localNetworkPrefix `
    -Tag $tags

# Define Site-to-Site Tunnel for Gateway

$vnetConnection = `
    New-AzureVirtualNetworkGatewayConnection `
        -Name $vnetConnectionName `
        -ResourceGroupName $rgName `
        -Location $location `
        -ConnectionType IPsec `
        -SharedKey $vnetConnectionKey `
        -Tag $tags `
        -VirtualNetworkGateway1 $vnetGateway `
        -LocalNetworkGateway2 $localGateway