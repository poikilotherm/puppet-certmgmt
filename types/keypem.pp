type Certmgmt::KeyPem = Pattern[
    /(?m:\A.*?-----BEGIN PRIVATE KEY-----.*?-----END PRIVATE KEY-----\Z)/,
    /(?m:\A.*?-----BEGIN RSA PRIVATE KEY-----.*?-----END RSA PRIVATE KEY-----\Z)/
]
