type Certmgmt::Certificate = Struct[{
  x509 => String[1],
  ensure => Optional[Enum['present','absent']],
  key => Optional[Certmgmt::KeyPem],
  chain => Optional[Variant[
      Certmgmt::X509PEM,
      Hash[String[1],Certmgmt::X509PEM,1]
    ]],
  combined => Optional[Variant[
      Boolean,
      Enum['key+cert','cert+chain']
    ]],
  file => Optional[String[1]],
  chainfile => Optional[String[1]],
  keyfile => Optional[String[1]],
  owner => Optional[String[1]],
  group => Optional[String[1]],
  mode => Optional[Pattern[/\A0[0-7]{3}\Z/]],
  }]
