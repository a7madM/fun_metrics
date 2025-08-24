# frozen_string_literal: true

module FunMetrics
  module Instrumentation
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def metrics_all!(only: nil, exclude: [])
        @_fun_metrics__instrumented ||= {}
        inst = self

        wrap_list = inst.instance_methods(false)
        wrap_list &= only if only
        wrap_list -= exclude.map(&:to_sym)

        wrap_list.each do |m|
          FunMetrics::Instrumentation.wrap_instance_method(inst, m)
        rescue StandardError
          # Handle error (e.g., log it)
        end

        singleton_class.class_eval do
          define_method(:method_added) do |meth|
            return super(meth) if @_adding_fun_metrics
            return super(meth) if meth == :initialize
            return super(meth) if only && !only.include?(meth)
            return super(meth) if exclude.include?(meth)
            next if inst.instance_variable_get(:@_fun_metrics__instrumented)&.[](meth)

            @_adding_fun_metrics = true
            begin
              FunMetrics::Instrumentation.wrap_instance_method(inst, meth)
            rescue StandardError
              # Handle error (e.g., log it)
            ensure
              @_adding_fun_metrics = false
            end
            super(meth)
          end
        end

        self
      end
    end

    def self.wrap_instance_method(klass, meth)
      traced = (klass.instance_variable_get(:@_fun_metrics__instrumented) || {})
      return if traced[meth]

      traced[meth] = true
      klass.instance_variable_set(:@_fun_metrics__instrumented, traced)

      orig = "__fun_metrics__#{meth}__"
      return if klass.instance_methods(false).include?(orig.to_sym)

      counter = FunMetrics.counter(
        labels: { class: klass.name, method: meth }
      )

      histogram = FunMetrics.histogram(labels: { class: klass.name, method: meth })

      klass.class_eval do
        alias_method orig, meth
        define_method(meth) do |*a, &blk|
          labels = { class: klass.name, method: meth }
          counter.increment(labels:)
          start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          result = send(orig, *a, &blk)
          duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
          histogram.observe(duration, labels:)
          result
        end
      end
    end
  end
end
