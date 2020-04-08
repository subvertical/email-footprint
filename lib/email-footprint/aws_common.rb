require 'aws-sdk'

module EmailFootprint
  class AwsCommon
    def self.initialization_options
      opts = {}

      if EmailFootprint.configuration.access_key_id && EmailFootprint.configuration.secret_access_key
        opts[:credentials] = Aws::Credentials.new(
          EmailFootprint.configuration.access_key_id,
          EmailFootprint.configuration.secret_access_key
        )
      end

      if EmailFootprint.configuration.aws_region
        opts[:region] = EmailFootprint.configuration.aws_region
      end

      opts
    end
  end
end
