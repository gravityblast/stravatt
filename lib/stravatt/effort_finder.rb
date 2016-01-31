module StravaTT
  class EffortFinder
    attr_reader :client, :start_time_limit, :end_time_limit, :segment_id

    def initialize user_access_token, start_time, end_time, segment_id
      validate_time_params start_time: start_time, end_time: end_time

      @client           = MiniStrava::Client.new user_access_token
      @start_time_limit = start_time
      @end_time_limit   = end_time
      @segment_id       = segment_id
    end

    def find_first
      efforts = client.activities(after: start_time_limit.to_i, before: end_time_limit.to_i).map do |a|
        find_effort_on_activity a.id
      end.compact

      efforts.sort! do |a, b|
        start_time_a = Time.parse a.start_date
        start_time_b = Time.parse b.start_date
        start_time_a <=> start_time_b
      end

      efforts.first
    end

    def find_effort_on_activity activity_id
      activity = client.activity activity_id
      effort = activity.segment_efforts.find do |se|
        se.segment.id == segment_id
      end
      return nil unless effort

      start_time = Time.parse effort.start_date
      end_time = start_time + effort.moving_time
      end_time > end_time_limit ? nil : effort
    rescue MiniStrava::Client::ResourceNotFound
    end

    private

    def validate_time_params params={}
      params.each do |k, v|
        raise TypeError.new "#{k} must be of type Time" unless v.is_a? Time
      end
    end
  end
end
