require 'aws-sdk'

module EmailFootprint
  class CampaignsTable < Database
    def get_item(options = {})
      campaign_id = options[:campaign_id]

      params = {
        key: { 'CampaignId' => campaign_id },
        table_name: EmailFootprint.configuration.campaigns_table
      }

      begin
        @client.get_item(params).item
      rescue Aws::DynamoDB::Errors::ServiceError => error
        EmailFootprint.logger.error "Unable to query the table: #{error}"
      end
    end
  end
end
