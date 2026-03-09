class Api::BaseController < ActionController::Base
  include Authentication, SetCurrentRequest

  allow_unauthenticated_access
  allow_bot_access

  before_action :require_bot_authentication

  protect_from_forgery with: :null_session

  private
    def require_bot_authentication
      token = request.headers["Authorization"]&.match(/\ABearer (.+)\z/)&.captures&.first&.strip

      if token && (bot = User.authenticate_bot(token))
        Current.user = bot
      else
        render json: { error: "Unauthorized" }, status: :unauthorized
      end
    end

    def require_room_permission!(permission)
      if @room.direct? && @room.users.include?(Current.user)
        return true
      end

      perm = Current.user.bot_room_permissions.find_by(room_id: @room.id)

      unless perm&.public_send(permission)
        render json: { error: "Forbidden" }, status: :forbidden
        return false
      end

      true
    end
end
