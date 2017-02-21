type Certmgmt::CertDefault = Struct[{
  ensure => Optional[Enum['present','absent']],
  chain => Optional[Variant[String[1],Array[String[1],1]]],
  combined => Optional[Boolean],
  owner => Optional[String[1]],
  group => Optional[String[1]],
  mode => Optional[Pattern[/\A0[0-7]{3}\Z/]],
  }]
