module StravaTT
  class TimeTrial
    attr_reader :segment_id, :start_time, :end_time

    def initialize segment_id, start_time, end_time
      @segment_id = segment_id
      @start_time = start_time
      @end_time   = end_time
    end

    def leaderboard users
      leaderboard = Leaderboard.new

      users.each do |user|
        raise TypeError.new unless user.is_a? User
        effort = first_effort_for user
        if effort
          leaderboard.add user.id, effort
        end
      end

      leaderboard.sort
    end

    private

    def first_effort_for user
      finder = EffortFinder.new user.access_token, start_time, end_time, segment_id
      finder.find_first
    end
  end
end
