require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'

run_puppet_install_helper

UNSUPPORTED_PLATFORMS = ['Suse','windows','AIX','Solaris','Debian']

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    hosts.each do |host|
      copy_module_to(host, :source => proj_root, :module_name => 'chronyd')

      # Make sure selinux is disabled before each test or apache won't work.
      if ! UNSUPPORTED_PLATFORMS.include?(fact('osfamily'))
        on host, puppet('apply', '-e',
                          %{"exec { 'setenforce 0': path   => '/bin:/sbin:/usr/bin:/usr/sbin', onlyif => 'which setenforce && getenforce | grep Enforcing', }"}),
                          { :acceptable_exit_codes => [0] }
      end
    end
  end
end
