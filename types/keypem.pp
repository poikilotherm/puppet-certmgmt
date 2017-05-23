type Certmgmt::KeyPem = Pattern[
    /(?m:\A-----BEGIN PRIVATE KEY-----[^-]+?-----END PRIVATE KEY-----.{0,2}\Z)/,
    /(?m:\A-----BEGIN RSA PRIVATE KEY-----[^-]+?-----END RSA PRIVATE KEY-----.{0,2}\Z)/,
]
