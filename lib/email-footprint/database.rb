require 'aws-sdk'

module EmailFootprint
  class Database
    def initialize
      @client = Aws::DynamoDB::Client.new(EmailFootprint::AwsCommon.initialization_options)
    end
  end
end
