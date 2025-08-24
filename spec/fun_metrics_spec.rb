# frozen_string_literal: true

require 'support/fake'
RSpec.describe FunMetrics do
  it 'has a version number' do
    expect(FunMetrics::VERSION).not_to be nil
  end

  describe 'Instrumentation' do
    it 'increments call counters' do
      obj = Fake.new
      3.times { obj.foo }
      2.times { obj.bar(5) }

      calls_metric = FunMetrics.calls_metric
      duration_metric = FunMetrics.duration_metric

      expect(calls_metric.get(labels: { class: obj.class.name, method: :foo })).to eq(3)
      expect(calls_metric.get(labels: { class: obj.class.name, method: :bar })).to eq(2)

      bar_duration_metric = duration_metric.get(labels: { class: obj.class.name, method: :bar })
      expect(bar_duration_metric).is_a?(Hash)
    end

    it 'records execution durations' do
      obj = Fake.new
      obj.foo

      duration_metric = FunMetrics.duration_metric

      observations = duration_metric.values

      expect(observations.count).not_to be_zero
    end

    it 'works with multiple instances' do
      a = Fake.new
      b = Fake.new

      expect { a.foo }.to change { FunMetrics.calls_metric.get(labels: { class: a.class.name, method: :foo }) }.by(1)
      expect { b.foo }.to change { FunMetrics.calls_metric.get(labels: { class: b.class.name, method: :foo }) }.by(1)
    end
  end
end
