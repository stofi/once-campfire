class BotRoomPermission < ApplicationRecord
  belongs_to :user
  belongs_to :room

  validates :user_id, uniqueness: { scope: :room_id }

  scope :readable, -> { where(can_read: true) }
  scope :writable, -> { where(can_write: true) }
end
