require 'spec_helper'

describe 'Certmgmt::Certificate', :if => Puppet::Util::Package.versioncmp(Puppet.version, '4.4.0') >= 0 do
  chain = {
    'root' => IO.read('spec/fixtures/files/chained_ca/root/root.pem'),
    'inter' => IO.read('spec/fixtures/files/chained_ca/inter/inter.pem')
  }
  servercert = IO.read('spec/fixtures/files/chained_ca/server.pem')
  serverkey = IO.read('spec/fixtures/files/chained_ca/server.key')

  only_cert = {
    'x509' => servercert,
  }
  it { is_expected.to allow_value(only_cert) }

  cert_and_key = {
    'x509' => servercert,
    'key' => serverkey
  }
  it { is_expected.to allow_value(cert_and_key) }

  cert_key_ca = {
      'x509' => servercert,
      'key' => serverkey,
      'chain' => chain['root']
  }
  it { is_expected.to allow_value(cert_key_ca) }

  cert_key_long_chain = {
    'x509' => servercert,
    'key' => serverkey,
    'chain' => { 'inter' => chain['inter'], 'root' => chain['root'] }
  }
  it { is_expected.to allow_value(cert_key_long_chain) }

  fail_cert_key_long_chain = {
    'x509' => servercert,
    'key' => serverkey,
    'chain' => [chain['inter'], chain['root']]
  }
  it { is_expected.not_to allow_value(fail_cert_key_long_chain) }
end
