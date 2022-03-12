# frozen_string_literal: true

module Msir
  class JetStreamProducer
    attr_reader :jet_stream

    def initialize
      connect = NATS.connect(
        servers: Msir.config.nats_servers,
        dont_randomize_servers: true,
        reconnect_time_wait: Msir.config.nats_reconnect_time_wait,
        max_reconnect_attempts: Msir.config.nats_max_reconnect_attempts
      )
      Msir.logger.write(:info, "Connected to #{connect.connected_server}")
      @jet_stream = connect.jetstream
      jet_stream.add_stream(name: Msir.config.nats_stream, subjects: [Msir.config.nats_messenger_subject])
    end

    def publish(subject, message)
      jet_stream.publish(subject, message)
      Msir.logger.write(:info, "#{Time.now} - Send: #{message}")
    end
  end
end
