require 'spec_helper'

describe 'certmgmt' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'without parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('certmgmt') }
      end

      context 'with certs in parameters' do
        # load certificats to be used later on
        certs = { 'long' => {}, 'short' => {} }
        # cert with a long chain (more than 1: root + intermediate)
        certs['long']['chain'] = {
          'inter' => IO.read('spec/fixtures/files/chained_ca/inter/inter.pem'),
          'root' => IO.read('spec/fixtures/files/chained_ca/root/root.pem')
        }
        certs['long']['x509'] = IO.read('spec/fixtures/files/chained_ca/server.pem')
        certs['long']['key'] = IO.read('spec/fixtures/files/chained_ca/server.key')

        # cert with a short chain (all certs directly signed by root)
        certs['short']['chain'] = IO.read('spec/fixtures/files/direct_ca/root.pem')
        certs['short']['x509'] = IO.read('spec/fixtures/files/direct_ca/server.pem')
        certs['short']['key'] = IO.read('spec/fixtures/files/direct_ca/server.key')

        certs.each do |type, data|
          context "with #{type} chain of ca certs" do
            let(:params) do
              {
                certs: { 'test' => data }
              }
            end

            it { is_expected.to compile.with_all_deps }
            it { is_expected.to contain_class('certmgmt') }
            it { is_expected.to contain_certmgmt__cert('test') }
          end
        end

        context 'with owner set' do
          let(:params) do
            {
              certs: { 'test' => {
                x509: certs['long']['x509'],
                owner: 'apache',
                file: '/etc/pki/tls/private/test.pem'
              } }
            }
          end

          it { is_expected.to contain_certmgmt__cert('test').with_owner('apache') }
          it { is_expected.to contain_file('/etc/pki/tls/private/test.pem').with_owner('apache') }
        end
      end
    end
  end
end
