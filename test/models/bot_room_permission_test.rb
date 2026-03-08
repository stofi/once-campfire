require "test_helper"

class BotRoomPermissionTest < ActiveSupport::TestCase
  test "belongs to user and room" do
    perm = bot_room_permissions(:bender_watercooler_read_write)
    assert_equal users(:bender), perm.user
    assert_equal rooms(:watercooler), perm.room
  end

  test "unique per user and room" do
    assert_raises(ActiveRecord::RecordInvalid) do
      BotRoomPermission.create!(user: users(:bender), room: rooms(:watercooler), can_read: true)
    end
  end

  test "scopes" do
    readable = BotRoomPermission.readable
    assert readable.include?(bot_room_permissions(:bender_watercooler_read_write))
    assert readable.include?(bot_room_permissions(:bender_hq_read_only))

    writable = BotRoomPermission.writable
    assert writable.include?(bot_room_permissions(:bender_watercooler_read_write))
    refute writable.include?(bot_room_permissions(:bender_hq_read_only))
  end
end
