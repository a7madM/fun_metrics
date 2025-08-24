# frozen_string_literal: true

class Fake
  def foo
    sleep 0.01
    'foo'
  end

  def bar(x)
    x * 2
  end
end

Fake.include FunMetrics::Instrumentation
Fake.metrics_all!
