class AddWebhookAllMessagesToBotRoomPermissions < ActiveRecord::Migration[8.2]
  def change
    add_column :bot_room_permissions, :webhook_all_messages, :boolean, default: false, null: false
  end
end
