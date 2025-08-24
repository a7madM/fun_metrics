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
        wrap_list.each { |m| FunMetrics::Instrumentation.wrap_instance_method(inst, m) }

        singleton_class.class_eval do
          define_method(:method_added) do |meth|
            return super(meth) if @_adding_fun_metrics
            return super(meth) if meth == :initialize
            return super(meth) if only && !only.include?(meth)
            return super(meth) if exclude.include?(meth)
            next if inst.instance_variable_get(:@_fun_metrics__instrumented)&.[](meth)

            @_adding_fun_metrics = true
            FunMetrics::Instrumentation.wrap_instance_method(inst, meth)
            @_adding_fun_metrics = false
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
        :"#{klass.name.gsub('::', '_').downcase}_#{meth}_calls",
        docstring: "Number of calls to #{klass}##{meth}",
        labels: []
      )
      histogram = FunMetrics.histogram(
        :"#{klass.name.gsub('::', '_').downcase}_#{meth}_duration_seconds",
        docstring: "Execution time of #{klass}##{meth}",
        labels: []
      )

      klass.class_eval do
        alias_method orig, meth
        define_method(meth) do |*a, &blk|
          counter.increment
          start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          result = send(orig, *a, &blk)
          duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
          histogram.observe(duration)
          result
        end
      end
    end
  end
end
