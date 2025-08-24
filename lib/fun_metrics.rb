# frozen_string_literal: true

require_relative 'fun_metrics/version'
require 'prometheus/client'

Dir[File.join(__dir__, 'fun_metrics', '*.rb')].sort.each { |f| require f }

module FunMetrics
  class << self
    attr_accessor :registry, :duration_metric, :calls_metric

    def configure
      self.registry ||= Prometheus::Client.registry

      # Histogram for durations
      self.duration_metric = Prometheus::Client::Histogram.new(
        :ruby_method_duration_seconds,
        docstring: 'Execution time of Ruby methods',
        labels: %i[class method]
      )
      registry.register(duration_metric)

      # Counter for calls
      self.calls_metric = Prometheus::Client::Counter.new(
        :ruby_method_calls_total,
        docstring: 'Total number of method calls',
        labels: %i[class method]
      )
      yield self if block_given?

      registry.register(calls_metric)
    end

    def counter(labels: {})
      calls_metric
    end

    def histogram(labels: {})
      duration_metric
    end
  end
end

FunMetrics.configure
