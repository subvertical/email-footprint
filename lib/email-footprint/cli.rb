require 'erb'
require 'thor'
require 'yaml'

module EmailFootprint
  class CLI < Thor
    def initialize(*args)
      super
      load_configuration
      EmailFootprint.configure do |config|
        config.aws_region                  = @configuration['aws_region']
        config.access_key_id               = @configuration['access_key_id']
        config.secret_access_key           = @configuration['secret_access_key']
        config.ses_configuration_set       = @configuration['ses_configuration_set']
        config.campaigns_table             = @configuration['campaigns_table']
        config.emails_table                = @configuration['emails_table']
        config.events_table                = @configuration['events_table']
        config.events_campaigns_index_name = @configuration['events_campaigns_index_name']
      end
    end

    no_commands do
      def load_configuration
        config_filename = 'email-footprint.yml.erb'
        puts "'#{config_filename}' does not exists." && exit(1) unless File.exist?(config_filename)
        @configuration = YAML.safe_load(ERB.new(File.read(config_filename)).result)
      end
    end

    desc 'send_emails', 'Send emails'
    def send_emails(campaign, sender, receiver)
      subject = '10 emails'
      tags    = [{ name: 'campaign_id', value: campaign }]

      html_body =
        '<h1>Amazon SES test (AWS SDK for Ruby)</h1>'\
        '<p>This email was sent with <a href="https://aws.amazon.com/ses/">'\
        'Amazon SES</a> using the <a href="https://aws.amazon.com/sdk-for-ruby/">'\
        'AWS SDK for Ruby</a>.'

      text_body = 'This email was sent with Amazon SES using the AWS SDK for Ruby.'

      10.times do |index|
        recipients = [receiver.sub('@', "+r#{index}@")]
        TaggedEmail.send(subject: subject, sender: sender, recipients: recipients, tags: tags,
                         body: { html_body: html_body, text_body: text_body })
        puts 'Sending email to ' + recipients.first
        sleep 1
      end
    end

    desc 'events_recipients', 'Get recipients from events table'
    def events_recipients(campaign_id, event_type)
      events_table = EventsTable.new
      events_table.query(campaign_id: campaign_id)

      puts events_table.recipients(event_type)
    end

    desc 'events_query', 'Query events table'
    def events_query(campaign_id)
      events_table = EventsTable.new
      events_table.query(campaign_id: campaign_id)

      events_table.counts.each do |event_type, count|
        puts "#{event_type}: #{count}"
      end
    end

    desc 'campaigns_query', 'Query campaigns table'
    def campaigns_query(campaign_id)
      campaigns_table = CampaignsTable.new
      campaign = campaigns_table.get_item(campaign_id: campaign_id)

      puts "CampaignId: #{campaign['CampaignId']}"
      puts "Open:\t\t#{campaign['Open'].to_i}"
      puts "Send:\t\t#{campaign['Send'].to_i}"
      puts "Click:\t\t#{campaign['Click'].to_i}"
      puts "Delivery:\t#{campaign['Delivery'].to_i}"
      puts "Bounce:\t\t#{campaign['Bounce'].to_i}"
    end

    desc 'store_email', 'Store email body'
    def store_email(campaign_id, recipient, body)
      emails_table = EmailsTable.new
      emails_table.store(body: body, recipient: recipient, campaign_id: campaign_id)
    end

    desc 'get_email', 'Get email from emails table'
    def get_email(campaign_id, recipient)
      emails_table = EmailsTable.new
      email = emails_table.get_item(campaign_id: campaign_id, recipient: recipient)

      puts "CampaignId: #{email['CampaignId']}"
      puts "Recipient: #{email['Recipient']}"
      puts "Body: #{email['Body']}"
    end
  end
end
