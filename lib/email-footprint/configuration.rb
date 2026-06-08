require 'active_support/core_ext/class'

module EmailFootprint
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end

  class Configuration
    class_attribute :aws_region, default: 'us-west-2'
    class_attribute :access_key_id
    class_attribute :secret_access_key
    class_attribute :ses_configuration_set
    class_attribute :campaigns_table
    class_attribute :emails_table
    class_attribute :events_table
    class_attribute :events_campaigns_index_name
  end
end
