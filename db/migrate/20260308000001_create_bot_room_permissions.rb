class CreateBotRoomPermissions < ActiveRecord::Migration[8.2]
  def change
    create_table :bot_room_permissions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :room, null: false, foreign_key: true
      t.boolean :can_read, default: false, null: false
      t.boolean :can_write, default: false, null: false
      t.timestamps
    end

    add_index :bot_room_permissions, %i[user_id room_id], unique: true
  end
end
