# frozen_string_literal: true

# require "prometheus/client/rack/exporter"

module FunMetrics
  class Middleware
    def self.use(app, path: '/metrics')
      # Use prometheus-client built-in exporter
      app.use Prometheus::Client::Rack::Exporter, path:, registry: FunMetrics.registry
    end
  end
end
