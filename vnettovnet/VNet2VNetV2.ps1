Register-AzureProvider `
-ProviderNamespace Microsoft.Compute -Force -Verbose

Register-AzureProvider `
-ProviderNamespace Microsoft.Storage -Force -Verbose

Register-AzureProvider `
-ProviderNamespace Microsoft.Network -Force -Verbose

Get-AzureProvider |
Select-Object `
-Property ProviderNamespace `
-ExpandProperty ResourceTypes

$location = "North Europe"


# Define a unique prefix for naming resources
# in this deployment

$prefix = "pcqarmdemo" # replace XXX with a unique lowercase value

# Define custom Tags to be used for new deployment

$tags = New-Object System.Collections.ArrayList
$tags.Add( @{ Name = "project"; Value = "demo" } )
$tags.Add( @{ Name = "costCenter"; Value = "0001" } )

# Create Resource Group if it doesn't already exist

$rgName = "${prefix}-rg"

If (!(Test-AzureResourceGroup `
  -ResourceGroupName $rgName)) {

    $rg = New-AzureResourceGroup `
    -Name $rgName `
    -Location $location `
    -Tag $tags -Verbose

  } Else {

    # Get Resource Group if already created

    $rg = Get-AzureResourceGroup `
    -Name $rgName -Verbose

  }

  # Create VNET1, if it doesn't already exist

  $vnet1Name = "${prefix}-vnet1"

  $subnet1Name = "${prefix}-subnet1"

  $subnet2Name = "GatewaySubnet"

  if (!(Test-AzureResource `
    -ResourceName $vnet1Name `
    -ResourceType "Microsoft.Network/virtualNetworks" `
    -ResourceGroupName $rgName)) {

      # Create VNET1

      $subnet1 = New-AzureVirtualNetworkSubnetConfig `
      -Name $subnet1Name `
      -AddressPrefix "10.0.1.0/24"

      $subnet2 = New-AzureVirtualNetworkSubnetConfig `
      -Name $subnet2Name `
      -AddressPrefix "10.0.2.0/28"

      $vnet1 = New-AzureVirtualNetwork `
      -Name $vnet1Name `
      -ResourceGroupName $rgName `
      -Location $location `
      -AddressPrefix "10.0.0.0/16" `
      -Subnet $subnet1, $subnet2 `
      -Tag $tags -Verbose

    } else {

      # Get VNET1 configuration

      $vnet1 = Get-AzureVirtualNetwork `
      -Name $vnet1Name `
      -ResourceGroupName $rgName -Verbose

    }

    # Create VNET2, if it doesn't already exist

    $vnet2Name = "${prefix}-vnet2"

    $subnet1Name = "${prefix}-subnet1"

    $subnet2Name = "GatewaySubnet"

    if (!(Test-AzureResource `
      -ResourceName $vnet2Name `
      -ResourceType "Microsoft.Network/virtualNetworks" `
      -ResourceGroupName $rgName)) {

        # Create VNET2

        $subnet1 = New-AzureVirtualNetworkSubnetConfig `
        -Name $subnet1Name `
        -AddressPrefix "10.1.1.0/24"

        $subnet2 = New-AzureVirtualNetworkSubnetConfig `
        -Name $subnet2Name `
        -AddressPrefix "10.1.2.0/28"

        $vnet2 = New-AzureVirtualNetwork `
        -Name $vnet2Name `
        -ResourceGroupName $rgName `
        -Location $location `
        -AddressPrefix "10.1.0.0/16" `
        -Subnet $subnet1, $subnet2 `
        -Tag $tags -Verbose

      } else {

        # Get VNET2 configuration

        $vnet2 = Get-AzureVirtualNetwork `
        -Name $vnet2Name `
        -ResourceGroupName $rgName -Verbose

      }



      # Register a Public IP for VNET1 Gateway

      $vnet1GatewayName = "${prefix}-gw1"

      $vnet1PublicGatewayVipName = "${prefix}-gw1vip"

      if (!(Test-AzureResource `
        -ResourceName $vnet1PublicGatewayVipName `
        -ResourceType "Microsoft.Network/publicIPAddresses" `
        -ResourceGroupName $rgName)) {

          # Create Public IP for VNET1 Gateway

          $vnet1PublicGatewayVip = New-AzurePublicIpAddress `
          -Name $vnet1PublicGatewayVipName `
          -ResourceGroupName $rgName `
          -Location $location `
          -AllocationMethod Dynamic `
          -DomainNameLabel $vnet1GatewayName `
          -Tag $tags -Verbose

        } else {

          # Get Public IP for VNET1 Gateway

          $vnet1PublicGatewayVip = Get-AzurePublicIpAddress `
          -Name $vnet1PublicGatewayVipName `
          -ResourceGroupName $rgName -Verbose

        }

        # Register a Public IP for VNET2 Gateway

        $vnet2GatewayName = "${prefix}-gw2"

        $vnet2PublicGatewayVipName = "${prefix}-gw2vip"

        if (!(Test-AzureResource `
          -ResourceName $vnet2PublicGatewayVipName `
          -ResourceType "Microsoft.Network/publicIPAddresses" `
          -ResourceGroupName $rgName)) {

            # Create Public IP for VNET2 Gateway

            $vnet2PublicGatewayVip = New-AzurePublicIpAddress `
            -Name $vnet2PublicGatewayVipName `
            -ResourceGroupName $rgName `
            -Location $location `
            -AllocationMethod Dynamic `
            -DomainNameLabel $vnet2GatewayName `
            -Tag $tags -Verbose

          } else {

            # Get Public IP for VNET2 Gateway

            $vnet2PublicGatewayVip = Get-AzurePublicIpAddress `
            -Name $vnet2PublicGatewayVipName `
            -ResourceGroupName $rgName -Verbose

          }

          # Create VNET1 Gateway if it doesn't exist

          if (!(Test-AzureResource `
            -ResourceName $vnet1GatewayName `
            -ResourceType "Microsoft.Network/virtualNetworkGateways" `
            -ResourceGroupName $rgName)) {

              # Create IP Config to attach VNET1 Gateway to VIP & Subnet

              $vnet1GatewayIpConfigName = "${prefix}-gw1ip"

              $vnet1GatewayIpConfig = `
              New-AzureVirtualNetworkGatewayIpConfig `
              -Name $vnet1GatewayIpConfigName `
              -PublicIpAddressId $vnet1PublicGatewayVip.Id `
              -PrivateIpAddress "10.0.2.4" `
              -SubnetId $vnet1.Subnets[1].Id -Verbose

              # Provision VNET1 Gateway

              $vnet1Gateway = New-AzureVirtualNetworkGateway `
              -Name $vnet1GatewayName `
              -ResourceGroupName $rgName `
              -Location $location `
              -GatewayType Vpn `
              -VpnType RouteBased `
              -IpConfigurations $vnet1GatewayIpConfig `
              -Tag $tags -Verbose

            } else {

              # Get current config of VNET1 Gateway

              $vnet1Gateway = Get-AzureVirtualNetworkGateway `
              -Name $vnet1GatewayName `
              -ResourceGroupName $rgName

            }

            # Create VNET2 Gateway if it doesn't exist

            if (!(Test-AzureResource `
              -ResourceName $vnet2GatewayName `
              -ResourceType "Microsoft.Network/virtualNetworkGateways" `
              -ResourceGroupName $rgName)) {

                # Create IP Config to attach VNET2 Gateway to VIP & Subnet

                $vnet2GatewayIpConfigName = "${prefix}-gw2ip"

                $vnet2GatewayIpConfig = `
                New-AzureVirtualNetworkGatewayIpConfig `
                -Name $vnet2GatewayIpConfigName `
                -PublicIpAddressId $vnet2PublicGatewayVip.Id `
                -PrivateIpAddress "10.1.2.4" `
                -SubnetId $vnet2.Subnets[1].Id -Verbose

                # Provision VNET2 Gateway

                $vnet2Gateway = New-AzureVirtualNetworkGateway `
                -Name $vnet2GatewayName `
                -ResourceGroupName $rgName `
                -Location $location `
                -GatewayType Vpn `
                -VpnType RouteBased `
                -IpConfigurations $vnet2GatewayIpConfig `
                -Tag $tags -Verbose

              } else {

                # Get current config of VNET2 Gateway

                $vnet2Gateway = Get-AzureVirtualNetworkGateway `
                -Name $vnet2GatewayName `
                -ResourceGroupName $rgName

              }


              # Create VNET1-to-VNET2 connection, if it doesn't exist

              $vnet12ConnectionName = "${prefix}-vnet-1-to-2-con"

              if (!(Test-AzureResource `
                -ResourceName $vnet12ConnectionName `
                -ResourceType "Microsoft.Network/connections" `
                -ResourceGroupName $rgName)) {

                  $vnet12Connection = `
                  New-AzureVirtualNetworkGatewayConnection `
                  -Name $vnet12ConnectionName `
                  -ResourceGroupName $rgName `
                  -Location $location `
                  -ConnectionType Vnet2Vnet `
                  -Tag $tags `
                  -VirtualNetworkGateway1 $vnet1Gateway `
                  -VirtualNetworkGateway2 $vnet2Gateway

                } else {

                  # Get Azure VNET1-to-VNET2 connection

                  $vnet12Connection = `
                  Get-AzureVirtualNetworkGatewayConnection `
                  -Name $vnet12ConnectionName `
                  -ResourceGroupName $rgName

                }

                # Create VNET2-to-VNET1 connection, if it doesn't exist

                $vnet21ConnectionName = "${prefix}-vnet-2-to-1-con"

                if (!(Test-AzureResource `
                  -ResourceName $vnet21ConnectionName `
                  -ResourceType "Microsoft.Network/connections" `
                  -ResourceGroupName $rgName)) {

                    # Get VNET Connection Shared Key

                    $vnetConnectionKey = `
                    Get-AzureVirtualNetworkGatewayConnectionSharedKey `
                    -Name $vnet12ConnectionName `
                    -ResourceGroupName $rgName

                    # Establish VNET2-to-VNET1 connection

                    $vnet21ConnectionName = "${prefix}-vnet-2-to-1-con"

                    $vnet21Connection = `
                    New-AzureVirtualNetworkGatewayConnection `
                    -Name $vnet21ConnectionName `
                    -ResourceGroupName $rgName `
                    -Location $location `
                    -ConnectionType Vnet2Vnet `
                    -SharedKey $vnetConnectionKey `
                    -Tag $tags `
                    -VirtualNetworkGateway1 $vnet2Gateway `
                    -VirtualNetworkGateway2 $vnet1Gateway

                  } else {

                    # Get Azure VNET2-to-VNET1 connection

                    $vnet21Connection = `
                    Get-AzureVirtualNetworkGatewayConnection `
                    -Name $vnet21ConnectionName `
                    -ResourceGroupName $rgName

                  }
