require 'spec_helper'


module StravaTT
  describe EffortFinder do
    let(:start_time) { Time.parse '2016-01-10T10:00:00Z' }
    let(:end_time)   { Time.parse '2016-01-10T18:00:00Z' }
    let(:segment_id) { 200 }
    let(:finder)     { EffortFinder.new 'xyz', start_time, end_time, segment_id }

    describe '.new' do
      it 'raise an exception if start_time or end_time are not Time objects' do
        expect{ EffortFinder.new 'x', :foo, Time.now, 1 }.to raise_error(TypeError)
        expect{ EffortFinder.new 'x', Time.now, :bar, 1 }.to raise_error(TypeError)
      end
    end

    describe '#find_effort_on_activity' do
      context 'activity not found' do
        it 'returns nil' do
          not_found_response = double('response', code: '404')
          allow(Net::HTTP).to receive(:start).and_return(not_found_response)
          expect(finder.find_effort_on_activity(1)).to be_nil
        end
      end

      context 'activity does not contain effort on selected segment' do
        it 'returns nil' do
          activity_id = 100
          segment_id  = 200
          activity = MiniStrava::Models::Activity.build({
            'id' => activity_id,
            'segment_efforts' => [{}, {}, {}]
          })

          expect(finder.client).to receive(:activity).with(activity_id).and_return(activity)
          expect(finder.find_effort_on_activity(activity.id)).to be_nil
        end
      end

      context 'segment effort is found but ended after time limit' do
        it 'returns nil' do
          activity_id = 100
          activity = MiniStrava::Models::Activity.build({
            'id' => activity_id,
            'segment_efforts' => [
              {},
              {
                'id' => 2,
                'start_date' => '2016-01-10T17:59:00Z',
                'moving_time' => 61,
                'segment' => {
                  'id' => segment_id
                }
              },
              {}
            ]
          })

          expect(finder.client).to receive(:activity).with(activity_id).and_return(activity)
          expect(finder.find_effort_on_activity(activity.id)).to be_nil
        end
      end

      context 'segment effort is found it ends before limit' do
        it 'returns nil' do
          activity_id = 100
          activity = MiniStrava::Models::Activity.build({
            'id' => activity_id,
            'segment_efforts' => [
              {},
              {
                'id' => 2,
                'start_date' => '2016-01-10T17:59:00Z',
                'moving_time' => 30,
                'segment' => {
                  'id' => segment_id
                }
              },
              {}
            ]
          })

          expect(finder.client).to receive(:activity).with(activity_id).and_return(activity)

          effort = finder.find_effort_on_activity activity.id
          expect(effort).to_not be_nil
          expect(effort.id).to eq(2)
        end
      end
    end

    describe '#find_first' do
      context 'no activity contains segment' do
        it 'returns nil' do
          activity_id = 100
          activity = MiniStrava::Models::Activity.build({
            'id' => activity_id,
            'segment_efforts' => [
              {},
              {
                'id' => 2,
                'start_date' => '2016-01-10T17:59:00Z',
                'moving_time' => 30,
                'segment' => {
                  'id' => segment_id + 1
                }
              },
              {}
            ]
          })

          expect(finder.client).to receive(:activities).with(after: start_time.to_i, before: end_time.to_i).and_return([activity])
          expect(finder.client).to receive(:activity).with(activity_id).and_return(activity)

          expect(finder.find_first).to be_nil
        end
      end

      context 'more than one activities contain segment' do
        it 'returns first performed' do
          activity_1 = MiniStrava::Models::Activity.build({
            'id' => 100,
            'segment_efforts' => [
              {
                'id' => 1,
                'start_date' => '2016-01-10T17:59:00Z',
                'moving_time' => 30,
                'segment' => {
                  'id' => segment_id
                }
              }
            ]
          })
          activity_2 = MiniStrava::Models::Activity.build({
            'id' => 200,
            'segment_efforts' => [
              {
                'id' => 2,
                'start_date' => '2016-01-10T17:30:00Z',
                'moving_time' => 30,
                'segment' => {
                  'id' => segment_id
                }
              },
            ]
          })

          expect(finder.client).to receive(:activities).with(after: start_time.to_i, before: end_time.to_i).and_return([activity_1, activity_2])
          expect(finder.client).to receive(:activity).with(activity_1.id).and_return(activity_1)
          expect(finder.client).to receive(:activity).with(activity_2.id).and_return(activity_2)

          effort = finder.find_first
          expect(effort).to_not be_nil
          expect(effort.id).to eq(2)
        end
      end
    end
  end
end
