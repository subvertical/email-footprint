require 'active_support'

module EmailFootprint
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end

  class Configuration
    include ActiveSupport::Configurable

    config_accessor(:aws_region) { 'us-west-2' }
    config_accessor(:access_key_id)
    config_accessor(:secret_access_key)
    config_accessor(:ses_configuration_set)
    config_accessor(:campaigns_table)
    config_accessor(:emails_table)
    config_accessor(:events_table)
    config_accessor(:events_campaigns_index_name)
  end
end
