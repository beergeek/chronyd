require 'spec_helper_acceptance'

describe 'chronyd class', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do

  context 'default parameters' do
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'chronyd': 
        servers      => ['192.168.1.1','192.168.2.2'],
        keyfile_hash => {'10' => 'password','11' => 'SHA1 HEX:1dc764e0791b11fa67efc7ecbc4b0d73f68a070c'}
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe package('chrony') do
      it { is_expected.to be_installed }
    end

    describe service('chronyd') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

  end
end
