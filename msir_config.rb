# frozen_string_literal: true

require 'anyway_config'

module Msir
  class Config < Anyway::Config 
    MSIR_NATS_SERVERS = ['nats://127.0.0.1:4222']
    MSIR_NATS_RECONNECT_TIME_WAIT = 0.5
    MSIR_NATS_MAX_RECONNECT_ATTEMPTS = 2
    MSIR_NATS_MESSENGER_STREAM = 'messenger'
    MSIR_NATS_MESSENGER_SUBJECT = 'inbox'
    MSIR_NATS_MESSENGER_DURABLE = 'messenger_cunsomer'

    config_name :msir

    attr_config(
      nats_servers: MSIR_NATS_SERVERS,
      nats_reconnect_time_wait: MSIR_NATS_RECONNECT_TIME_WAIT, 
      nats_max_reconnect_attempts: MSIR_NATS_MAX_RECONNECT_ATTEMPTS,
      nats_stream: MSIR_NATS_MESSENGER_STREAM, 
      nats_messenger_subject: MSIR_NATS_MESSENGER_SUBJECT, 
      otel_service_name: 'msir_messenger',
    )

    coerce_types nats_servers: {type: :string, array: true}
  end
  
  def self.config
    @config ||= Config.new 
  end
end
