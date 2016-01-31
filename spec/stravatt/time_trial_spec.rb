require 'spec_helper'

module StravaTT
  describe TimeTrial do
    let(:start_time) { Time.now - 30}
    let(:end_time)   { Time.now - 10}
    let(:tt)         { TimeTrial.new 1, start_time, end_time }

    describe '#leaderboard' do
      context 'invalid user types' do
        it 'raises a TypeError' do
          expect do
            tt.leaderboard({id: 1, access_token: 'xyz'})
          end.to raise_error(TypeError)
        end
      end

      context 'valid users' do
        def build_effort moving_time
          MiniStrava::Models::SegmentEffort.build({
            'moving_time' => moving_time,
            'segment' => [
              {
                'id' => 1
              }
            ]
          })
        end

        def mock_finder user, effort, segment_id
          finder = double('finder', find_first: effort)
          expect(EffortFinder).to receive(:new).with(user.access_token, start_time, end_time, segment_id).and_return(finder)
        end

        it 'returns a sorted leaderboard' do
          user_1 = User.new 1, 'x1'
          effort_1 = build_effort 10
          mock_finder user_1, effort_1, 1

          user_2 = User.new 2, 'x2'
          effort_2 = build_effort 30
          mock_finder user_2, effort_2, 1

          user_3 = User.new 3, 'x3'
          mock_finder user_3, nil, 1

          user_4 = User.new 4, 'x4'
          effort_4 = build_effort 5
          mock_finder user_4, effort_4, 1

          leaderboard = tt.leaderboard [user_1, user_2, user_3, user_4]
          expected = [
            { user_id: user_4.id, effort: effort_4 },
            { user_id: user_1.id, effort: effort_1 },
            { user_id: user_2.id, effort: effort_2 },
            { user_id: user_3.id, effort: nil },
          ]

          expect(leaderboard[0]).to eq({user_id: user_4.id, effort: effort_4})
        end
      end
    end
  end
end
