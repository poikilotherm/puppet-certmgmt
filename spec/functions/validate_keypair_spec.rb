require 'spec_helper'

describe 'certmgmt::validate_keypair' do
  title = 'test'
  cert_match = IO.read('spec/fixtures/files/direct_ca/server.pem')
  key_match = IO.read('spec/fixtures/files/direct_ca/server.key')
  key_fail = IO.read('spec/fixtures/files/direct_ca/root.key')

  it 'runs with certmgmt::validate_keypair("<title>", "<valid cert here>", "<valid key here>") and return true' do
    is_expected.to run.with_params(title, cert_match, key_match).and_return(true)
  end
  it 'fails with certmgmt::validate_keypair("<title>", "<valid cert here>", "<valid key here>") but not matching pair and raise exception' do
    is_expected.to run.with_params(title, cert_match, key_fail).and_raise_error(Puppet::ParseError)
  end
  it 'fails with certmgmt::validate_keypair("<title>", "invalid cert", "<valid key here>") and raise exception' do
    is_expected.to run.with_params(title, 'cert_match', key_fail).and_raise_error(Puppet::ParseError)
  end
  it 'fails with certmgmt::validate_keypair("<title>", "<valid cert here>", "invalid key") and raise exception' do
    is_expected.to run.with_params(title, cert_match, 'key_fail').and_raise_error(Puppet::ParseError)
  end
end
