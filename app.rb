# frozen_string_literal: true

require 'logger'
require 'nats/client'
require 'roda'

class Log
  private

  attr_reader :logger

  public

  def initialize
    @logger = Logger.new(STDOUT)
  end

  def write(level, message)
    logger.send(level, message)
  end
end

class Config
  MSIR_NATS_SERVERS = ['nats://127.0.0.1:4222']
  MSIR_NATS_RECONNECT_TIME_WAIT = 0.5
  MSIR_NATS_MAX_RECONNECT_ATTEMPTS = 2
  MSIR_NATS_MESSENGER_STREAM = 'messenger'
  MSIR_NATS_MESSENGER_SUBJECT = 'inbox'
  MSIR_NATS_MESSENGER_DURABLE = 'messenger_cunsomer'

  attr_reader :data

  def initialize
    data = {
      nats_servers: ENV['MSIR_NATS_SERVERS']&.split(',') || MSIR_NATS_SERVERS,
      nats_reconnect_time_wait: ENV['MSIR_NATS_RECONNECT_TIME_WAIT'] || MSIR_NATS_RECONNECT_TIME_WAIT, 
      nats_max_reconnect_attempts: ENV['MSIR_NATS_MAX_RECONNECT_ATTEMPTS'] || MSIR_NATS_MAX_RECONNECT_ATTEMPTS,
      nats_stream: ENV['MSIR_NATS_MESSENGER_STREAM'] || MSIR_NATS_MESSENGER_STREAM, 
      nats_messenger_subject: ENV['MSIR_NATS_MESSENGER_SUBJECT'] || MSIR_NATS_MESSENGER_SUBJECT, 
    }
    @data = Struct.new(*data.keys).new(*data.values)
  end
end

class App < Roda
  plugin :json

  config = Config.new.data
  logger = Log.new

  route do |r|
    r.on 'api' do
      r.on 'v1' do
        r.on 'message' do
          # curl -v -H "Content-Type: application/json" -X POST --data "message=ok" http://localhost:9292/api/v1/message
          r.post do
            send_message(config, logger, config.nats_messenger_subject, message_params(r.params))
          end
        end
      end
    end
  end

  def send_message(config, logger, subject, message)
    MessageToQueueService.add(config, logger, subject, message)
  end

  def message_params(params)
    params[:message]
  end
end

class MessageToQueueService
  def self.add(config, logger, subject, message)
    producer ||= JetStreamProducer.new(config: config, logger: logger)
    producer.publish(subject, message)
    {error: nil, ok: true} 
  end
end

class JetStreamProducer
  attr_reader :jet_stream, :logger

  def initialize(config:, logger:)
    @logger = logger
    cluster_opts = {
      servers: config.nats_servers,
      dont_randomize_servers: true,
      reconnect_time_wait: config.nats_reconnect_time_wait,
      max_reconnect_attempts: config.nats_max_reconnect_attempts
    }

    connect = NATS.connect(cluster_opts)
    logger.write(:info, "Connected to #{connect.connected_server}")
    @jet_stream = connect.jetstream
    jet_stream.add_stream(name: config.nats_stream, subjects: [config.nats_messenger_subject])
  end

  def publish(subject, message)
    jet_stream.publish(subject, message)
    logger.write(:info, "#{Time.now} - Send: #{message}")
  end
end

