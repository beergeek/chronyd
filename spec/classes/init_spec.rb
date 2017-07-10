require 'spec_helper'
describe 'chronyd' do
  context 'with default values for all parameters' do
    let(:params) do
      {
        'servers'       => ['192.168.2.2','192.168.4.4'],
        'keyfile_hash'  => {'10' => 'password','11' => 'SHA1 HEX:1dc764e0791b11fa67efc7ecbc4b0d73f68a070c'},
      }
    end

    it { should contain_class('chronyd') }

    it do
      should contain_package('chrony_package').with({
        'ensure' => 'present',
        'name'   => 'chrony'
      })
    end

    it do
      should contain_file('chrony_config').with({
        'ensure'  => 'file',
        'path'    => '/etc/chrony.conf',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'require' => 'Package[chrony_package]',
      })
    end

    it do
      should contain_file('chrony_keyfile').with({
        'ensure'  => 'file',
        'path'    => '/etc/chrony.keys',
        'replace' => true,
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'require' => 'Package[chrony_package]',
      })
    end

    it do
      should contain_service('chrony_service').with({
        'ensure'    => 'running',
        'enable'    => true,
        'name'      => 'chronyd',
        'subscribe' => 'File[chrony_config]',
      })
    end
  end

  context 'with default values for all parameters, but on an unsupported operating system' do
    let(:facts) do
      {
        :os  => {
          :family  => 'Debian',
          :name    => 'Debian',
          :release => {
            :full  => '8.9.0',
            :major => '8',
            :minor => '9'
          }
        }
      }
    end
    let(:params) do
      {
        'servers'       => ['192.168.2.2','192.168.4.4'],
        'keyfile_hash'  => {'10' => 'password','11' => 'SHA1 HEX:1dc764e0791b11fa67efc7ecbc4b0d73f68a070c'},
      }
    end

    it 'Raise an error if not RHEL7' do
      expect { catalogue }.to raise_error(Puppet::Error, /This module is for RedHat 7, not Debian 8/)
    end
  end
end
