require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|
  c.before :each do
    # Ensure that we don't accidentally cache facts and environment
    # between test cases.
    Facter::Util::Loader.any_instance.stubs(:load_all)
    Facter.clear
    Facter.clear_messages

    # Store any environment variables away to be restored later
    @old_env = {}
    ENV.each_key {|k| @old_env[k] = ENV[k]}

    if ENV['STRICT_VARIABLES'] == 'yes'
      Puppet.settings[:strict_variables]=true
    end
  end
  c.default_facts = {
    :os => {
      :family        => 'RedHat',
      :name          => 'RedHat',
      :release       => {
        :full        => '7.2.1511',
        :major       => '7',
        :minor       => '2'
      },
      :hardware      => 'x86_64',
      :architecture  => 'x86_64',
    }
  }
end

at_exit { RSpec::Puppet::Coverage.report! }
