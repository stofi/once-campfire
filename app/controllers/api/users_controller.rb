class Api::UsersController < Api::BaseController
  def index
    @users = User.active.ordered

    render json: @users.map { |user|
      {
        id: user.id,
        name: user.name,
        bot: user.bot?,
        bio: user.bio
      }
    }
  end
end
