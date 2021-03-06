class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # has_many :messages
  has_many :posts, dependent: :destroy
  has_many :reactions, dependent: :destroy
  has_many :comments, dependent: :destroy
  
  has_one_attached :avatar
  has_one_attached :cover_picture

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  # Fix: remove later but after removing make sure that the user get updated properly
  # validates :username, presence: true, uniqueness: true, length: { in: 3..15 }
  # validates :email, presence: true, uniqueness: true, format: Devise.email_regexp
  # validates :fullname, presence: true, length: { in: 3..50 }
  # validates :bio, presence: true, length: { maximum: 200 }
  # validates :profession, presence: true, length: { in: 3..50 }
  # validates :city, presence: true, length: { in: 3..50 }
  # validates :gender, presence: true
  # validates :password, presence: true, length: { in: 6..20 }

  has_many :friendships, dependent: :destroy

  has_many :inverted_friendships, -> { where confirmed: false }, class_name: 'Friendship', foreign_key: 'friend_id'
  has_many :friend_requests, through: :inverted_friendships, source: :user

  has_many :pending_friendships, -> { where confirmed: false }, class_name: 'Friendship', foreign_key: 'user_id'
  has_many :pending_friends, through: :pending_friendships, source: :friend

  has_many :confirmed_friendships, -> { where confirmed: true }, class_name: 'Friendship'
  has_many :friends, through: :confirmed_friendships

  has_many :messages, dependent: :destroy
  has_many :rooms, through: :messages

  def friends_and_own_posts
    users = friends
    Post.where(user: users).or(Post.where(user: self)).order('created_at DESC')
  end

  def confirm_friend(friend)
    inverted_friendships.find_by(user_id: friend).update(confirmed: true)
  end

  def friend?(user)
    friends.include?(user)
  end

  def pending_friend?(user)
    pending_friends.include?(user)
  end

  def new_friend?(user)
    friend_requests.include?(user)
  end
  
  def last_friend_requests
    friend_requests.order(created_at: :desc).limit(4)
  end
end
