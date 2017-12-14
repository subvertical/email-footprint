require 'aws-sdk'

module EmailFootprint
  class EventsTable < Database
    attr_reader :results

    def query(options = {})
      @results = []
      campaign_id = options[:campaign_id]

      params = {
        expression_attribute_values: { ':campaign_id' => campaign_id },
        key_condition_expression: 'CampaignId = :campaign_id',
        table_name: EmailFootprint.configuration.events_table,
        index_name: EmailFootprint.configuration.events_campaigns_index_name
      }

      @query_response = @client.query(params)

      loop do
        @results << @query_response.items
        break unless (last_evaluated_key = @query_response.last_evaluated_key)
        @query_response = @client.query(params.merge(exclusive_start_key: last_evaluated_key))
      end

      @results = @results.flatten
    end

    def events(event_type)
      @results.select { |hash| hash['EventType'] == event_type }
    end

    def recipients(event_type)
      events(event_type).map { |hash| hash['Recipient'] }.flatten.uniq
    end

    def event_types
      @event_types ||= @results.map { |hash| hash['EventType'] }.uniq
    end

    def count(event_type)
      @results.select { |hash| hash['EventType'] == event_type }.count
    end

    def counts
      Hash[event_types.collect { |et| [et, count(et)] }]
    end
  end
end
