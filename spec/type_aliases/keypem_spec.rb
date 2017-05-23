require 'spec_helper'

describe 'Certmgmt::Keypem', if: Puppet::Util::Package.versioncmp(Puppet.version, '4.4.0') >= 0 do
  key = IO.read('spec/fixtures/files/testcert.key')
  it { is_expected.to allow_value(key) }
end
