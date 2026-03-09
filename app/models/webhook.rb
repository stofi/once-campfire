require "net/http"
require "uri"

class Webhook < ApplicationRecord
  ENDPOINT_TIMEOUT = 7.seconds

  belongs_to :user

  def deliver(message)
    post(payload(message))
  rescue Net::OpenTimeout, Net::ReadTimeout
    # Silently ignore timeouts — bot can use the API to respond
  end

  private
    def post(payload)
      http.request \
        Net::HTTP::Post.new(uri, "Content-Type" => "application/json").tap { |request| request.body = payload }
    end

    def http
      Net::HTTP.new(uri.host, uri.port).tap do |http|
        http.use_ssl = (uri.scheme == "https")
        http.open_timeout = ENDPOINT_TIMEOUT
        http.read_timeout = ENDPOINT_TIMEOUT
      end
    end

    def uri
      @uri ||= URI(url)
    end

    def payload(message)
      room = message.room
      {
        user:    { id: message.creator.id, name: message.creator.name },
        room:    { id: room.id, name: room_name(room), type: room.type.demodulize.downcase, path: room_bot_messages_path(message) },
        message: { id: message.id, body: { html: message.body.body, plain: without_recipient_mentions(message.plain_text_body) }, path: message_path(message) },
        mentions: message.mentionees.map { |u| { id: u.id, name: u.name, bot: u.bot? } }
      }.to_json
    end

    def room_name(room)
      if room.direct?
        room.users.where.not(id: user.id).pluck(:name).to_sentence.presence || user.name
      else
        room.name
      end
    end

    def message_path(message)
      Rails.application.routes.url_helpers.room_at_message_path(message.room, message)
    end

    def room_bot_messages_path(message)
      Rails.application.routes.url_helpers.room_bot_messages_path(message.room, user.bot_key)
    end

    def without_recipient_mentions(body)
      body \
        .gsub(user.attachable_plain_text_representation(nil), "") # Remove mentions of the recipient user
        .gsub(/\A\p{Space}+|\p{Space}+\z/, "") # Remove leading and trailing whitespace uncluding unicode spaces
    end
end
