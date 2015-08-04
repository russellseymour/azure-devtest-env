Configuration ConfigurePrimaryZone
{
  param ($MachineName, $ZoneName, $SecondaryServer, $MasterServer, $CondForwardZoneName, $CondForwardMasterServer)

  Import-DscResource -ModuleName xDnsServer

  Node $MachineName
  {
    #Install the DNS Role
    WindowsFeature DNSFeature
    {
      Ensure = "Present"
      Name = "DNS"
    }
    WindowsFeature DNSTools
    {
      Ensure = "Present"
      Name = "RSAT-DNS-Server"
      DependsOn               = "[WindowsFeature]DNSFeature"
    }
    Script ConfigureForwardZone
    {
        SetScript = {
          Write-Verbose "Add primary zone $using:ZoneName"
          Add-DnsServerPrimaryZone -Name $ZoneName -ZoneFile "custcom.local.dns" -DynamicUpdate "NonsecureAndSecure"
          Add-DnsServerConditionalForwarderZone -Name $CondForwardZoneName -MasterServers $CondForwardMasterServer -PassThru
        }
        #Dummy test script to force the set script to run.
        TestScript              = {
            $zones = (Get-DnsServer).ServerZone.ZoneName
            foreach ($zone in $zones) {
                Write-Verbose "Current zone in the dns server: $zone "
                if ($zone -eq $using:ZoneName) {
                    Write-Verbose "Zone already set... skipping ConfigureForwardZone"
                    return $true
                }
            }
            Write-Verbose "Zone not present... adding zone $using:ZoneName"
            return $false
        }
        GetScript               = { <# This must return a hash table #> }
        DependsOn               = "[WindowsFeature]DNSTools"
    }
    xDnsServerZoneTransfer TransferToSecondaryServer
    {
        Name = $ZoneName
        Type = "Specific"
        SecondaryServer = $SecondaryServer
        DependsOn               = "[Script]ConfigureForwardZone"
    }
  }
}

#ConfigurePrimaryZone -MachineName "dnssrv-11" -ZoneName "custcom.local" -SecondaryServer "10.208.2.5" -TransferType "Specific"
#Start-DscConfiguration .\ConfigurePrimaryZone -Wait -Verbose
