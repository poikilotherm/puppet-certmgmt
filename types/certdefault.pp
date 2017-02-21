type Certmgmt::CertDefault = Struct[{
  ensure => Optional[Enum['present','absent']],
  chain => Optional[Variant[
      Certmgmt::X509PEM,
      Hash[String[1],Certmgmt::X509PEM,1]
    ]],
  combined => Optional[Variant[
      Boolean,
      Enum['key+cert','cert+chain']
    ]],
  owner => Optional[String[1]],
  group => Optional[String[1]],
  mode => Optional[Pattern[/\A0[0-7]{3}\Z/]],
  }]
