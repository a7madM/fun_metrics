# frozen_string_literal: true

require 'active_support/concern'

module FunMetrics
  module Trackable
    extend ActiveSupport::Concern

    included do
      include FunMetrics::Instrumentation
      metrics_all! if respond_to?(:metrics_all!)
    end
  end
end
