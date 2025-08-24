# FunMetrics
[![Gem Version](https://badge.fury.io/rb/fun_metrics.svg)](https://badge.fury.io/rb/fun_metrics)
[![CI](https://github.com/ahmed/fun_metrics/actions/workflows/ci.yml/badge.svg)](https://github.com/ahmed/fun_metrics/actions/workflows/ci.yml)

FunMetrics provides a simple, declarative DSL to add instrumentation and track key metrics for your Ruby classes and methods. Keep your business logic clean and make metrics fun again!

## Features

-   Declaratively track method calls, execution time, and exceptions.
-   Easily extendable with custom backends.
-   Clean, simple API for custom metrics.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add fun_metrics
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install fun_metrics
```

## Usage

### 1. Configuration

First, configure the metrics backend. For example, in a Rails initializer:

```ruby
# config/initializers/fun_metrics.rb
FunMetrics.configure do |config|
    # For development, you can use the logger backend
    config.backend = FunMetrics::Backend::Logger.new

    # For production, you might use StatsD
    # config.backend = FunMetrics::Backend::Statsd.new(host: 'localhost', port: 8125, namespace: 'my_app')
end
```

### 2. Instrumenting a Class

Include the `FunMetrics::Trackable` module in your class and use the `metrics_all!` macro to automatically instrument methods.

```ruby
class UserReport
    include FunMetrics

    # This will automatically track:
    # - A counter for every call (`user_report.generate.count`)
    # - The execution time (`user_report.generate.duration`)
    # - A counter for any exceptions (`user_report.generate.errors`)
    include FunMetrics::Trackable

    def initialize(user)
        @user = user
    end

    def generate
        # Your complex report generation logic here...
        sleep 2

        # You can also add custom metrics anywhere
        metrics.increment('reports.generated', tags: { plan: @user.plan })
        metrics.gauge('users.active_report_generation', 1)
    end
end
```

When `UserReport.new(user).generate` is called, FunMetrics will automatically send the metrics to your configured backend.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ahmed/fun_metrics. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/ahmed/fun_metrics/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the FunMetrics project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ahmed/fun_metrics/blob/main/CODE_OF_CONDUCT.md).
