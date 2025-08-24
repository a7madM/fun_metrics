# frozen_string_literal: true

# Auto-instrument all classes in /app/*.rb with FunMetrics::Instrumentation

Dir[File.expand_path('../../app/*.rb', __dir__)].each { |file| require file }

ObjectSpace.each_object(Class) do |klass|
  next if klass.name.nil? || klass.name.start_with?('FunMetrics') # skip gem's own classes

  begin
    klass.include FunMetrics::Instrumentation
    klass.metrics_all! if klass.respond_to?(:metrics_all!)
  rescue StandardError
  end
end
