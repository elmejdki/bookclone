class Room < ApplicationRecord
  has_many :messages, dependent: :destroy
  has_many :users, through: :messages

  scope :user_rooms, ->(user) { user.rooms.includes(:users).order(last_message: :desc) }

  def side_user(current_user)
    if self.users[0] == current_user
      users[1]
    else
      users[0]
    end
  end
end
