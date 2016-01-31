# StravaTT

[![Build Status](https://travis-ci.org/pilu/stravatt.png)](https://travis-ci.org/pilu/stravatt)


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stravatt'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stravatt

## Usage

```ruby
require 'time'
require 'stravatt'

segment_id = SEGMENT_ID
start_time = Time.parse DATE_STRING
end_time = Time.parse DATE_STRING

tt = StravaTT.new segment_id, start_time, end_time
tt.leaderboard [
  StravaTT::User.new(YOUR_INTERNAL_ID, USER_TOKEN),
  StravaTT::User.new(YOUR_INTERNAL_ID, USER_TOKEN),
  StravaTT::User.new(YOUR_INTERNAL_ID, USER_TOKEN)
]

=> [
    {
      :user_id=>1,
      :effort=>
      #<MiniStrava::Models::SegmentEffort:0x007f83a32a4fd0
      ...
    },
    {
      :user_id=>2,
      :effort=>
      #<MiniStrava::Models::SegmentEffort:0x007f83a32a4fd0
      ...
    },
    ...
   ]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pilu/stravatt.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

