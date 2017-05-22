require 'spec_helper'

describe 'certmgmt::cert', :type => :define do
  let(:pre_condition) { 'class {"::certmgmt": }' }
  let(:title) do
    '#test'
  end

  # load certificats to be used later on
  certs = { 'long' => {}, 'short' => {}}
  join_chain = {}
  # cert with a long chain (more than 1: root + intermediate)
  certs['long']['chain'] = {
    'inter' => IO.read('spec/fixtures/files/chained_ca/inter/inter.pem'),
    'root' => IO.read('spec/fixtures/files/chained_ca/root/root.pem')
  }
  certs['long']['x509'] = IO.read('spec/fixtures/files/chained_ca/server.pem')
  certs['long']['key'] = IO.read('spec/fixtures/files/chained_ca/server.key')
  join_chain['long'] = certs['long']['chain']['inter']+certs['long']['chain']['root']

  # cert with a short chain (all certs directly signed by root)
  certs['short']['chain'] = IO.read('spec/fixtures/files/direct_ca/root.pem')
  certs['short']['x509'] = IO.read('spec/fixtures/files/direct_ca/server.pem')
  certs['short']['key'] = IO.read('spec/fixtures/files/direct_ca/server.key')
  join_chain['short'] = certs['short']['chain']

  combos = [true, false, 'key+cert', 'cert+chain']

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      certs.each do |type, data|
        context "with #{type} chain of ca certs" do
          combos.each do |combo|
            context "and combining = #{combo}" do
              content = ""
              case combo
              when true
                content = "#{data['key']}#{data['x509']}#{join_chain[type]}"
              when false
                content = "#{data['x509']}"
              when 'key+cert'
                content = "#{data['key']}#{data['x509']}"
              when 'cert+chain'
                content = "#{data['x509']}#{join_chain[type]}"
              end

              let(:params) do
                data.merge({
                  :combined => combo,
                  :file => '/etc/pki/tls/server.pem'
                })
              end

              it "should compile and contain resource for #{type} chains" do
                is_expected.to compile.with_all_deps
                is_expected.to contain_certmgmt__cert('#test')
              end

              it { is_expected.to contain_file('/etc/pki/tls/server.pem') }
              it { is_expected.to contain_file('/etc/pki/tls/server.pem').with_content(content) }
            end
          end
        end
      end

      case facts[:osfamily]
      when 'RedHat'
        #it { is_expected.to contain_package('xyz') }
        #...
      end
    end
  end
end


# vim: sw=2 ts=2 sts=2 et :
