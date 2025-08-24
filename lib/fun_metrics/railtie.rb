# frozen_string_literal: true

require 'rails/railtie'

module FunMetrics
  class Railtie < ::Rails::Railtie
    initializer 'fun_metrics.auto_include_trackable' do
      ActiveSupport.on_load(:active_record) do
        include FunMetrics::Trackable if defined?(FunMetrics::Trackable)
      end
      
      ActiveSupport.on_load(:action_controller) do
        include FunMetrics::Trackable if defined?(FunMetrics::Trackable)
      end

      
      
      # Optionally, include in other Rails components
      # ActiveSupport.on_load(:action_view) do
      #   include FunMetrics::Trackable if defined?(FunMetrics::Trackable)
      # end
    end
  end
end
