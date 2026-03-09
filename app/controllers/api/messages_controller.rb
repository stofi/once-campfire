class Api::MessagesController < Api::BaseController
  include ActiveStorage::SetCurrent

  before_action :set_room

  def index
    require_room_permission!(:can_read) || return

    messages = @room.messages.with_creator.with_boosts.ordered

    if params[:since].present?
      since = Time.iso8601(params[:since])
      messages = messages.where("messages.created_at > ?", since)
    end

    messages = messages.limit(params.fetch(:limit, 50).to_i.clamp(1, 100))

    render json: messages.map { |msg| message_json(msg) }
  end

  def create
    require_room_permission!(:can_write) || return

    body = params[:body] || request.body.read.force_encoding("UTF-8")
    @message = @room.messages.create!(body: body, creator: Current.user)
    @message.broadcast_create

    render json: {
      id: @message.id,
      body: @message.plain_text_body,
      created_at: @message.created_at.iso8601
    }, status: :created
  end

  private
    def set_room
      @room = Room.find_by(id: params[:room_id])
      render(json: { error: "Not found" }, status: :not_found) unless @room
    end

    def message_json(msg)
      json = {
        id: msg.id,
        body: msg.plain_text_body,
        html: msg.body&.body&.to_html,
        author: {
          id: msg.creator.id,
          name: msg.creator.name,
          bot: msg.creator.bot?
        },
        attachment: msg.attachment? ? attachment_json(msg.attachment) : nil,
        boosts: msg.boosts.ordered.map { |b|
          { content: b.content, user: { id: b.booster.id, name: b.booster.name } }
        },
        created_at: msg.created_at.iso8601,
        updated_at: msg.updated_at.iso8601
      }
      json.compact
    end

    def attachment_json(attachment)
      {
        url: url_for(attachment),
        filename: attachment.filename.to_s,
        content_type: attachment.content_type,
        byte_size: attachment.byte_size
      }
    end
end
