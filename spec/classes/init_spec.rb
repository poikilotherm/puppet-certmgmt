require 'spec_helper'

describe 'certmgmt' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('certmgmt') }

      case facts[:osfamily]
      when 'RedHat'
        #it { is_expected.to contain_package('xyz') }
        #...
      end
    end
  end
end
