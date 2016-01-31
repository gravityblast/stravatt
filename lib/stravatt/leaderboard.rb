module StravaTT
  class Leaderboard
    attr_reader :store

    def initialize
      @store = {}
    end

    def add user_id, effort
      store[user_id] = effort
    end

    def sort
      results = store.sort do |(a_id, a_effort), (b_id, b_effort)|
        return a unless b_effort
        return b unless a_effort

        a_effort.moving_time <=> b_effort.moving_time
      end

      results.map do |(id, effort)|
        {
          user_id: id,
          effort: effort
        }
      end
    end
  end
end
