require 'spec_helper'

describe 'Certmgmt::X509pem', :type => :type_alias, :if => Puppet::Util::Package.versioncmp(Puppet.version, '4.4.0') >= 0 do
  cert = IO.read('spec/fixtures/files/testcert.pem')
  it { is_expected.to allow_value(cert) }
end
