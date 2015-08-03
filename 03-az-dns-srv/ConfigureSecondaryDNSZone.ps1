Configuration ConfigureSecondaryZone
{
    param ($MachineName, $ZoneName, $SecondaryServer, $MasterServer)

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
      xDnsServerSecondaryZone SecondaryZone
      {
        Ensure        = 'Present'
        Name          = $ZoneName
        MasterServers = $MasterServer
        DependsOn               = "[WindowsFeature]DNSTools"
      }
    }
}

#ConfigureSecondaryZone -MachineName "dnssrv-21" -ZoneName "custcom.local" -MasterServer "10.208.2.4"
#Start-DscConfiguration .\ConfigureSecondaryZone -Wait -Verbose
