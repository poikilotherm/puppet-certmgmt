type Certmgmt::Certificate = Struct[{
  x509 => String[1],
  ensure => Optional[Enum['present','absent']],
  key => Optional[String[1]],
  chain => Optional[Variant[String[1],Array[String[1],1]]],
  combined => Optional[Boolean],
  file => Optional[String[1]],
  keyfile => Optional[String[1]],
  owner => Optional[String[1]],
  group => Optional[String[1]],
  mode => Optional[Pattern[/\A0[0-7]{3}\Z/]],
  }]
