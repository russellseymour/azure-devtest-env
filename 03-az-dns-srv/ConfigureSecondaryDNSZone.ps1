Configuration ConfigureSecondaryZone
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
    }
}
