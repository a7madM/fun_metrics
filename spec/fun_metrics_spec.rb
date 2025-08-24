# frozen_string_literal: true
RSpec.describe FunMetrics do
  it 'has a version number' do
    expect(FunMetrics::VERSION).not_to be nil
  end


  class TestClass
    include FunMetrics::Instrumentation
    metrics_all!

    def foo
      sleep 0.01
      'foo'
    end

    def bar(x)
      x * 2
    end
  end

  describe 'Instrumentation' do
    it 'increments call counters' do
      obj = TestClass.new
      3.times { obj.foo }
      2.times { obj.bar(5) }

      counter_foo = FunMetrics.metrics[:testclass_foo_calls]
      counter_bar = FunMetrics.metrics[:testclass_bar_calls]

      expect(counter_foo.get).to eq(3)
      expect(counter_bar.get).to eq(2)
    end

    it 'records execution durations' do
      obj = TestClass.new
      obj.foo

      histogram = FunMetrics.metrics[:testclass_foo_duration_seconds]
      observations = histogram.values
      
      # histogram stores counts + sum of observed values
      expect(observations.count).to eq(1)
      expect(observations.flatten[1]["sum"]).to be > 0.0
    end

    it 'works with multiple instances' do
      a = TestClass.new
      b = TestClass.new

      expect { a.foo }.to change { FunMetrics.metrics[:testclass_foo_calls].get }.by(1)
      expect { b.foo }.to change { FunMetrics.metrics[:testclass_foo_calls].get }.by(1)
    end
  end
end
