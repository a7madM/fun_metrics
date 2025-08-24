# frozen_string_literal: true

require_relative 'lib/fun_metrics/version'

Gem::Specification.new do |spec|
  spec.name = 'fun_metrics'
  spec.version = FunMetrics::VERSION
  spec.authors = ['Ahmed Magdy']
  spec.email = ['ahmadmgdi94@gmail.com']

  spec.summary       = 'Auto-instrument Ruby methods with Prometheus metrics'
  spec.description   = 'Counts calls and measures execution time of Ruby methods, exposing metrics to Prometheus.'
  spec.homepage      = 'https://github.com/a7madM/fun_metrics'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/a7madM/fun_metrics'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.add_dependency 'prometheus-client', '>= 4.0'
  spec.add_dependency 'rack', '>= 2.0'
  spec.add_development_dependency 'rspec'

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
