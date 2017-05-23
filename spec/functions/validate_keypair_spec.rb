require 'spec_helper'

describe 'certmgmt::validate_keypair', :type => :puppet_function do
  title = 'test'
  cert_match = IO.read('spec/fixtures/files/direct_ca/server.pem')
  key_match = IO.read('spec/fixtures/files/direct_ca/server.key')
  key_fail = IO.read('spec/fixtures/files/direct_ca/root.key')

  it "should run with matching public/private keypair" do
    is_expected.to run.with_params(title, cert_match, key_match)
  end
  it "should fail with non-matching public/private keypair" do
    is_expected.not_to run.with_params(title, cert_match, key_fail)
  end
  it "should fail with non-valid X509 certificate" do
    is_expected.not_to run.with_params(title, "cert_match", key_fail)
  end
  it "should fail with non-valid private key" do
    is_expected.not_to run.with_params(title, cert_match, "key_fail")
  end
end
