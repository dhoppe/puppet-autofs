require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'
require 'rspec/retry'

begin
  require 'pry'
rescue LoadError
end

RSpec.configure do |c|
  # Project root
  module_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # show retry status in spec process
  c.verbose_retry = true
  # show exception that triggers a retry if verbose_retry is set to true
  c.display_try_failure_messages = true

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and deps
    hosts.each do |host|
      install_puppet_agent_on(hosts, options)
      install_dev_puppet_module_on(host, :source => module_root, :module_name => 'autofs',
          :target_module_path => '/opt/puppetlabs/puppet/modules')
      # Due to RE-6764, running yum update renders the machine unable to install
      # other software. Thus this workaround. - thanks to Gareth Rushgrove's work for this
      #if fact_on(host, 'operatingsystem') == 'RedHat'
      #  on(host, 'mv /etc/yum.repos.d/redhat.repo /etc/yum.repos.d/internal-mirror.repo')
      #end
      #on(host, 'yum update -y -q') if fact_on(host, 'osfamily') == 'RedHat'

      on host, puppet('module', 'install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1]}
      on host, puppet('module', 'install', 'puppetlabs-concat'), { :acceptable_exit_codes => [0,1]}
    end
  end
end
