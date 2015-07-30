Configuration ConfigurePrimaryZone
{
  param ($MachineName)

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
          Add-DnsServerPrimaryZone -Name "custcom.local" -ZoneFile "custcom.local.dns"
          Set-DnsServerPrimaryZone -Name "custcom.local" -DynamicUpdate "NonsecureAndSecure" -PassThru
        }
        #Dummy test script to force the set script to run.
        TestScript              = { return $false }
        GetScript               = { <# This must return a hash table #> }
        DependsOn               = "[WindowsFeature]DNSTools"
    }
    LocalConfigurationManager
    {
        RebootNodeIfNeeded = $true
    }
  }
}
