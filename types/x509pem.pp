type Certmgmt::X509PEM = Pattern[
      /(?m:\A-----BEGIN CERTIFICATE-----[^\-]+?-----END CERTIFICATE-----.?\Z)/
  ]
