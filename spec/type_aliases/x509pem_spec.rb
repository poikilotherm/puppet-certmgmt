require 'spec_helper'

describe 'Certmgmt::X509pem', if: Puppet::Util::Package.versioncmp(Puppet.version, '4.4.0') >= 0 do
  cert = IO.read('spec/fixtures/files/testcert.pem')
  it 'expect to allow cert' do
    is_expected.to allow_value(cert)
  end
end
