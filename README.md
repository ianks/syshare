# Syshare

`syshare` provides some useful components for
[dry-system](https://dry-rb.org/gems/dry-system/). The goal is to be able to
easily add dependencies to your project, in a robust and easy way. The gem will
take care of important best practices for you, such as:

- Managing the lifecycle of a dependency (starting, shutting down, etc.)
- Ensure the resources are safely wrapped (i.e. using a connection pool when neccesary)
- Configuring the environment
- Adding logging
- And more...

## Components

### Redis

The `redis` component sets up a connection to a Redis server with a few bonuses:

- Sets up sane defaults for timeouts
- Uses a a connection pool by default
- Adds a logger if one is available on the app container
- Automatically detects the `REDIS_URL` environment variable and uses it if present

[View All Settings](https://github.com/ianks/syshare/blob/main/lib/syshare/boot/redis.rb#L5)

```ruby
require 'dry/system/container'
require 'syshare'

class App < Dry::System::Container
  boot(:redis, from: :syshare) do
    configure do |config|
      config.driver = 'hiredis'
    end
  end
end

# Later in your code...
App[:redis].ping # => "PONG"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/syshare. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/syshare/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Syshare project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/syshare/blob/main/CODE_OF_CONDUCT.md).
