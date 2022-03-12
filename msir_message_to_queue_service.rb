# frozen_string_literal: true

module Msir
  class MessageToQueueService
    def self.add(subject, message)
      producer ||= Msir::JetStreamProducer.new
      tracer = OpenTelemetry.tracer_provider.tracer('my-tracer')

      tracer.in_span('message_to_queue') do |span|
        producer.publish(subject, message)
      end

      {error: nil, ok: true} 
    end
  end
end
