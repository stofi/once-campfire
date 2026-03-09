class Api::RoomsController < Api::BaseController
  def index
    permitted_room_ids = Current.user.bot_room_permissions.where("can_read = ? OR can_write = ?", true, true).pluck(:room_id)
    direct_room_ids = Current.user.memberships.joins(:room).where(room: { type: "Rooms::Direct" }).pluck(:room_id)

    @rooms = Room.where(id: permitted_room_ids | direct_room_ids).ordered

    render json: @rooms.map { |room|
      if room.direct?
        { id: room.id, name: room_display_name(room), type: "direct", can_read: true, can_write: true }
      else
        permission = Current.user.bot_room_permissions.find_by(room_id: room.id)
        { id: room.id, name: room.name, type: room.type.demodulize.downcase, can_read: permission&.can_read || false, can_write: permission&.can_write || false }
      end
    }
  end

  private
    def room_display_name(room)
      if room.direct?
        room.users.where.not(id: Current.user.id).pluck(:name).to_sentence.presence || Current.user.name
      else
        room.name
      end
    end
end
