require 'spec_helper'
describe 'certmgmt' do
  context 'with default values for all parameters' do
    it { should contain_class('certmgmt') }
  end
end
