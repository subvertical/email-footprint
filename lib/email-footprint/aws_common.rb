require 'aws-sdk'

module EmailFootprint
  class AwsCommon
    def self.credentials
      Aws::Credentials.new(EmailFootprint.configuration.access_key_id,
                           EmailFootprint.configuration.secret_access_key)
    end

    def self.initialization_options
      {
        region:      EmailFootprint.configuration.aws_region,
        credentials: EmailFootprint::AwsCommon.credentials
      }
    end
  end
end
