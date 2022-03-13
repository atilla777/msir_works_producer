# frozen_string_literal: true

module Msir
  module SendMessage
    private

    def send_message(response)
      Msir::MessageToQueueService.add(
        Msir.config.nats_messenger_subject,
        message(response)
      )
    end

    def message(response)
      msg = JSON.parse(response.body.read).fetch('message', '')
      raise Msir::EmptyMessageErorr if msg.empty?
      msg
    rescue Msir::EmptyMessageErorr => e
      Msir.logger.write(:error, "Can`t send message to queue - #{e}")
    end
  end
end
