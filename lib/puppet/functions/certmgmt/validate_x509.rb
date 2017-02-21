Puppet::Functions.create_function(:'certmgmt::validate_x509') do
  # Verify that a given certificate is a valid X509 PEM formated cert.
  # @param x509 The PEM formatted X509 certificate
  # @return [Boolean] Returns true when valid, raises exception when not
  dispatch :validate do
    param 'String[1]', :x509
    return_type 'Boolean'
  end

  # Verify that a given certificate is a valid X509 PEM formated cert
  # and was signed by the given CA (which is checked to be valid, too).
  # @param x509 The PEM formatted X509 certificate
  # @param x509ca The PEM formatted X509 CA certificate
  # @return [Boolean] Returns true when verified successfully, raises exception when not
  dispatch :validateca do
    param 'String[1]', :x509
    param 'String[1]', :x509ca
    return_type 'Boolean'
  end

  # Verify that a given certificate is a valid X509 PEM formated cert
  # and was signed by the CA including the intermediates (which is checked to be valid, too).
  # @param x509 The PEM formatted X509 certificate
  # @param x509ca Array of PEM formatted X509 CA certificates ("the chain")
  # @return [Boolean] Returns true when verified successfully, raises exception when not
  dispatch :validatecahash do
    param 'String[1]', :x509
    param 'Hash[String[1],String[1],1]', :x509cachain
    return_type 'Boolean'
  end

  def validate(x509)
    require 'openssl'
    begin
      cert = OpenSSL::X509::Certificate.new(x509)
      true
    rescue OpenSSL::X509::CertificateError => e
      raise Puppet::ParseError, "Not a valid x509 certificate: #{e}"
    end
  end

  def validateca(x509, x509ca)
    require 'openssl'
    begin
      cert = OpenSSL::X509::Certificate.new(x509)
    rescue OpenSSL::X509::CertificateError => e
      raise Puppet::ParseError, "Not a valid x509 certificate: #{e}"
    end
    begin
      cacert = OpenSSL::X509::Certificate.new(x509ca)
    rescue OpenSSL::X509::CertificateError => e
      raise Puppet::ParseError, "Not a valid x509 CA certificate: #{e}"
    end
    if ! cert.verify(cacert.public_key)
      raise Puppet::ParseError, "Certificate was not signed by given CA: #{e}"
    end
  end

  def validatecahash(x509, x509cachain)
    require 'openssl'
    begin
      cert = OpenSSL::X509::Certificate.new(x509)
    rescue OpenSSL::X509::CertificateError => e
      raise Puppet::ParseError, "Not a valid x509 certificate: #{e}"
    end
    x509cachain.each { |ca, x509ca|
      begin
        cacert = OpenSSL::X509::Certificate.new(x509ca)
      rescue OpenSSL::X509::CertificateError => e
        raise Puppet::ParseError, "Not a valid x509 CA certificate for #{ca}: #{e}"
      end
      # verify every level of the chain
      if ! cert.verify(cacert.public_key)
        raise Puppet::ParseError, "Certificate was not signed by given CA #{ca}: #{e}"
      end
      # for the next iteration set the current CA cert
      # to cert as the next level needs always to be verified
      # by the last
      cert = cacert
    }
    true
  end
end
