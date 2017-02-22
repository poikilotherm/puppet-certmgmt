Puppet::Functions.create_function(:'certmgmt::validate_keypair') do
  # Verify that a given certificate is a valid X509 PEM formated cert.
  # @param x509 The PEM formatted X509 certificate
  # @param key The key in PEM format (either PKCS1 or PKCS8)
  # @return [Boolean] Returns true when valid, raises exception when not
  dispatch :validate do
    param 'String[1]', :x509
    param 'String[1]', :key
    return_type 'Boolean'
  end

  def validate(x509, key)
    require 'openssl'
    begin
      cert = OpenSSL::X509::Certificate.new(x509)
      true
    rescue OpenSSL::X509::CertificateError => e
      raise Puppet::ParseError, "Not a valid x509 certificate: #{e}"
    end
    begin
      key = OpenSSL::PKey.read(key)
    rescue ArgumentError => e
      raise Puppet::ParseError, "Not a valid private key: #{e}"
    end

    unless cert.check_private_key(key)
      raise Puppet::ParseError, 'Private key does not match certificate.'
    end
    true
  end
end
