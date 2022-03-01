# frozen_string_literal: true

require 'roda'

class App < Roda
  plugin :json

  route do |r|
    r.on 'api' do
      r.on 'v1' do
        r.on 'messages' do
          # curl -v -H "Content-Type: application/json" -X POST --data "message=ok" http://localhost:9292/api/v1/messages
          r.post do
            send_messages(messages_params(r.params))
          end
        end
      end
    end
  end

  def send_messages(messages)
    MessageToQueueService.add(messages)
  end

  def messages_params(params)
    params[:messages]
  end
end

class MessageToQueueService
  def self.add(message)
    puts 'add' 
    {error: nil, ok: true} 
  end
end
