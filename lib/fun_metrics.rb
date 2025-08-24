# frozen_string_literal: true

require_relative 'fun_metrics/version'
require 'prometheus/client'

Dir[File.join(__dir__, 'fun_metrics', '*.rb')].sort.each { |f| require f }

module FunMetrics
  class << self
    attr_accessor :registry, :metrics

    def configure
      self.registry ||= Prometheus::Client.registry
      self.metrics ||= {}

      yield self if block_given?
    end

    def counter(name, docstring:, labels: [])
      metrics[name] ||= Prometheus::Client::Counter.new(name, docstring:, labels:)
      begin
        registry.register(metrics[name])
      rescue StandardError
        nil
      end
      metrics[name]
    end

    def histogram(name, docstring:, labels: [])
      metrics[name] ||= Prometheus::Client::Histogram.new(name, docstring:, labels:)
      begin
        registry.register(metrics[name])
      rescue StandardError
        nil
      end
      metrics[name]
    end
  end
end

FunMetrics.configure
