# vim: ai ts=2 sts=2 et sw=2 ft=ruby
begin
  require 'vagrant'
rescue LoadError
  raise "The Vagrant oVirt v4 plugin must be run within Vagrant."
end


# This is a sanity check to make sure no one is attempting to install
# this into an early Vagrant version.
# Note: snapshots only available in 1.9.1+
if Vagrant::VERSION < '1.9.1'
  raise "The Vagrant oVirt v4 plugin is only compatible with Vagrant 1.9.1+"
end

module VagrantPlugins
  module OVirtProvider
    class Plugin < Vagrant.plugin('2')
      name "ovirt4"
      description <<-DESC
      Vagrant plugin to manage oVirt v4 machines.
      DESC

      provider_capability('ovirt4', 'snapshot_list') do
        require_relative 'cap/snapshot_list'
        Cap::SnapshotList
      end

      config("ovirt4", :provider) do
        require_relative "config"
        Config
      end

      provider("ovirt4", parallel: true) do
        # Setup logging and i18n
        setup_logging
        setup_i18n

        require_relative "provider"
        Provider
      end

      # This initializes the internationalization strings.
      def self.setup_i18n
        I18n.load_path << File.expand_path("locales/en.yml",
          OVirtProvider.source_root)
        I18n.reload!
      end

      # This sets up our log level to be whatever VAGRANT_LOG is.
      def self.setup_logging
        require "log4r"

        level = nil
        begin
          level = Log4r.const_get(ENV["VAGRANT_LOG"].upcase)
        rescue NameError
          # This means that the logging constant wasn't found,
          # which is fine. We just keep `level` as `nil`. But
          # we tell the user.
          level = nil
        end

        # Some constants, such as "true" resolve to booleans, so the
        # above error checking doesn't catch it. This will check to make
        # sure that the log level is an integer, as Log4r requires.
        level = nil if !level.is_a?(Integer)

        # Set the logging level on all "vagrant" namespaced
        # logs as long as we have a valid level.
        if level
          logger = Log4r::Logger.new("vagrant_ovirt4")
          logger.outputters = Log4r::Outputter.stderr
          logger.level = level
          logger = nil
        end
      end
    end
  end
end

