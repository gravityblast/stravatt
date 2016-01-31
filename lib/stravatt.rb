require 'mini_strava'
require 'stravatt/version'
require 'stravatt/effort_finder'
require 'stravatt/time_trial'
require 'stravatt/user'
require 'stravatt/leaderboard'

module StravaTT
  def self.new segment_id, start_time, end_time
    TimeTrial.new segment_id, start_time, end_time
  end
end
