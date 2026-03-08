class Api::RoomsController < Api::BaseController
  def index
    room_ids = Current.user.bot_room_permissions.where("can_read = ? OR can_write = ?", true, true).pluck(:room_id)
    @rooms = Room.where(id: room_ids).ordered

    render json: @rooms.map { |room|
      permission = Current.user.bot_room_permissions.find_by(room_id: room.id)
      {
        id: room.id,
        name: room.name,
        type: room.type.demodulize.downcase,
        can_read: permission&.can_read || false,
        can_write: permission&.can_write || false
      }
    }
  end
end
