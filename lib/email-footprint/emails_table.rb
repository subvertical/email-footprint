require 'aws-sdk'

module EmailFootprint
  class EmailsTable < Database
    def get_item(options = {})
      recipient = options[:recipient]
      campaign_id = options[:campaign_id]

      params = {
        key: { 'CampaignId' => campaign_id, 'Recipient' => recipient },
        table_name: EmailFootprint.configuration.emails_table
      }

      begin
        @client.get_item(params).item
      rescue Aws::DynamoDB::Errors::ServiceError => error
        EmailFootprint.logger.error "Unable to query the table: #{error}"
      end
  end

    def store(options = {})
      params = {
        table_name: EmailFootprint.configuration.emails_table,
        item: {
          Recipient:  options[:recipient],
          CampaignId: options[:campaign_id],
          Body:       options[:body]
        }
      }

      begin
        @client.put_item(params)
        EmailFootprint.logger.info 'Stored the email.'
      rescue Aws::DynamoDB::Errors::ServiceError => error
        EmailFootprint.logger.error "Unable to store the email: #{error}"
      end
    end
  end
end
