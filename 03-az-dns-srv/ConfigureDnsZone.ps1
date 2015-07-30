Configuration ConfigureDNSZones
{
  Node dnssrv-01
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
          Add-DnsServerPrimaryZone -Name "custcom.local" -ZoneFile "custcom.local.dns"
          Set-DnsServerPrimaryZone -Name "custcom.local" -DynamicUpdate "NonsecureAndSecure" -PassThru
        }
        #Dummy test script to force the set script to run.
        TestScript              = { return $false }
        GetScript               = { <# This must return a hash table #> }
        DependsOn               = "[WindowsFeature]DNSTools"
    }
  }
  Node dnssrv-02
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
          Add-DnsServerSecondaryZone -Name "custcom.local" -ZoneFile "custcom.local.dns" -MasterServers 10.208.2.4
        }
        #Dummy test script to force the set script to run.
        TestScript              = { return $false }
        GetScript               = { <# This must return a hash table #> }
        DependsOn               = "[WindowsFeature]DNSTools"
    }
  }
}
