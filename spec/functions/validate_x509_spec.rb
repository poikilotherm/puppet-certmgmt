require 'spec_helper'

describe 'certmgmt::validate_x509' do
  certs = { long: {}, short: {} }
  # cert with a long chain (more than 1: root + intermediate)
  certs[:long][:chain] = {
    'inter' => IO.read('spec/fixtures/files/chained_ca/inter/inter.pem'),
    'root' => IO.read('spec/fixtures/files/chained_ca/root/root.pem')
  }
  certs[:long][:x509] = IO.read('spec/fixtures/files/chained_ca/server.pem')

  # cert with a short chain (all certs directly signed by root)
  certs[:short][:chain] = IO.read('spec/fixtures/files/direct_ca/root.pem')
  certs[:short][:x509] = IO.read('spec/fixtures/files/direct_ca/server.pem')

  # test :validate
  context 'with a x509 certificate only' do
    it 'runs with certmgmt::validate_x509("<valid cert here>") and return true' do
      is_expected.to run.with_params(certs[:short][:x509]).and_return(true)
    end
    it { is_expected.to run.with_params('invalid string').and_raise_error(Puppet::ParseError) }
  end

  # test :validateca
  context 'with a x509 certificate plus a ca cert' do
    it 'runs with certmgmt::validate_x509("<valid cert here>", "<valid ca cert here>") and return true' do
      is_expected.to run.with_params(certs[:short][:x509], certs[:short][:chain]).and_return(true)
    end
    it 'fails with certmgmt::validate_x509("<valid cert here>", "<valid ca cert here>") but cert not signed by ca and raise exception' do
      is_expected.to run.with_params(certs[:long][:x509], certs[:short][:chain]).and_raise_error(Puppet::ParseError)
    end
    it 'fails with certmgmt::validate_x509("invalid string", "<valid ca cert here>") and raise exception' do
      is_expected.to run.with_params('invalid string', certs[:short][:chain]).and_raise_error(Puppet::ParseError)
    end
    it 'fails with certmgmt::validate_x509("<valid cert here>", "invalid string") and raise exception' do
      is_expected.to run.with_params(certs[:short][:x509], 'invalid string').and_raise_error(Puppet::ParseError)
    end
  end

  # test :validatecahash
  context 'with a x509 certificate plus a ca cert chain (as a hash)' do
    it 'runs with certmgmt::validate_x509("<valid cert here>", {valid ca cert chain hash here}) and return true' do
      is_expected.to run.with_params(certs[:long][:x509], certs[:long][:chain]).and_return(true)
    end
    it 'fails with certmgmt::validate_x509("<valid cert here>", {valid ca cert chain hash here}) but cert not signed by ca and raise exception' do
      is_expected.to run.with_params(certs[:short][:x509], certs[:long][:chain]).and_raise_error(Puppet::ParseError)
    end
    it 'fails with certmgmt::validate_x509("invalid string", {valid ca cert chain hash here}) and raise exception' do
      is_expected.to run.with_params('invalid string', certs[:long][:chain]).and_raise_error(Puppet::ParseError)
    end
    it 'fails with certmgmt::validate_x509("<valid cert here>", {INvalid ca cert chain hash}) and raise exception' do
      invalid_chain = { 'inter' => certs[:long][:chain]['inter'], 'root' => 'invalid cert' }
      is_expected.to run.with_params(certs[:long][:x509], invalid_chain).and_raise_error(Puppet::ParseError)
    end
  end
end
