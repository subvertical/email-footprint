require 'aws-sdk'

module EmailFootprint
  class TaggedEmail
    def self.send(options = {})
      tags       = options[:tags]
      sender     = options[:sender]
      subject    = options[:subject]
      recipients = options[:recipients]
      html_body  = options[:body][:html_body]
      text_body  = options[:body][:text_body]

      encoding = 'UTF-8'

      begin
        ses_client = Aws::SES::Client.new(EmailFootprint::AwsCommon.initialization_options)

        ses_client.send_email(
          destination: { to_addresses: recipients },
          message: {
            body: {
              html: { charset: encoding, data: html_body },
              text: { charset: encoding, data: text_body }
            },
            subject: { charset: encoding, data: subject }
          },
          source: sender,
          configuration_set_name: EmailFootprint.configuration.ses_configuration_set,
          tags: tags
        )
        EmailFootprint.logger.info 'Email sent!'
      rescue Aws::SES::Errors::ServiceError => error
        EmailFootprint.logger.error "Email was not sent: #{error}"
      end
    end
  end
end
