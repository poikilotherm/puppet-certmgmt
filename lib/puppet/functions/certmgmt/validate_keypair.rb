Puppet::Functions.create_function(:'certmgmt::validate_keypair') do
  # Verify that a given certificate is a valid X509 PEM formated cert.
  # @param title The string to print on errors for easier identification which certs are invalid
  # @param x509 The PEM formatted X509 certificate
  # @param key The key in PEM format (either PKCS1 or PKCS8)
  # @return [Boolean] Returns true when valid, raises exception when not
  dispatch :validate do
    param 'String[1]', :title
    param 'String[1]', :x509
    param 'String[1]', :key
    return_type 'Boolean'
  end

  def validate(title, x509, key)
    require 'openssl'
    begin
      cert = OpenSSL::X509::Certificate.new(x509)
      key = OpenSSL::PKey.read(key)

      unless cert.check_private_key(key)
        raise Puppet::ParseError, "Private key for \"#{title}\" does not match certificate."
      end

      true
    rescue OpenSSL::X509::CertificateError => e
      raise Puppet::ParseError, "Not a valid x509 certificate for \"#{title}\": #{e}"
    rescue OpenSSL::PKey::PKeyError => e
      raise Puppet::ParseError, "Not a valid private key for \"#{title}\": #{e}"
    end
  end
end
