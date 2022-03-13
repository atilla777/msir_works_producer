# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, ENV['APP_ENV'] || :development)

require 'logger'
require 'nats/client'
require 'opentelemetry-sdk'
require 'opentelemetry-exporter-otlp'
require 'opentelemetry-instrumentation-rack'

Dir[File.join(__dir__, 'msir', '**', '*.rb')].each { |file| require file }

OpenTelemetry::SDK.configure do |c|
  c.service_name = 'msir_works_producer'
  c.use 'OpenTelemetry::Instrumentation::Rack'
end

module Msir
  class App < Roda
    include Msir::SendMessage

    plugin :json

    route do |r|
      r.on 'api' do
        r.on 'v1' do
          r.on 'message' do
            # curl -v -H "Content-Type: application/json" -X POST --data '{"message":"ok"}' http://localhost:9292/api/v1/message
            r.post do
              send_message(r)
            end
          end
        end
      end
    end
  end
end
