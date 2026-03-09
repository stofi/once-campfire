class Accounts::BotsController < ApplicationController
  before_action :ensure_can_administer
  before_action :set_bot, only: %i[ edit update destroy ]

  def index
    @bots = User.active_bots.ordered
  end

  def new
    @bot = User.active_bots.new
    @rooms = Room.without_directs.ordered
  end

  def create
    bot = User.create_bot! bot_params
    update_room_permissions(bot)
    redirect_to account_bots_url
  end

  def edit
    @rooms = Room.without_directs.ordered
  end

  def update
    @bot.update_bot! bot_params
    update_room_permissions(@bot)
    redirect_to account_bots_url
  end

  def destroy
    @bot.deactivate
    redirect_to account_bots_url
  end

  private
    def set_bot
      @bot = User.active_bots.find(params[:id])
    end

    def bot_params
      params.require(:user).permit(:name, :avatar, :webhook_url)
    end

    def update_room_permissions(bot)
      permissions = params[:room_permissions] || {}

      bot.bot_room_permissions.delete_all

      permissions.each do |room_id, perms|
        next unless perms[:can_read] == "1" || perms[:can_write] == "1"
        bot.bot_room_permissions.create!(
          room_id: room_id,
          can_read: perms[:can_read] == "1",
          can_write: perms[:can_write] == "1",
          webhook_all_messages: perms[:webhook_all_messages] == "1"
        )
      end
    end
end
