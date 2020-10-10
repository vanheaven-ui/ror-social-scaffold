class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true, length: { maximum: 20 }

  has_many :posts
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :friendships, foreign_key: :invitor_id, class_name: :Friendship, dependent: :destroy
  has_many :inverse_friendships, foreign_key: :invitee_id, class_name: :Friendship
  has_many :friend_invites, through: :inverse_friendships, source: :invitor
  has_many :approved_friendships, ->{ where status: true }, class_name: :Friendship, foreign_key: :invitor_id 
  has_many :approved_friends, through: :approved_friendships, source: :invitee
  has_many :accepted_friendships, ->{ where status: true }, class_name: :Friendship, foreign_key: :invitee_id
  has_many :accepted_friends, through: :accepted_friendships, source: :invitor
  has_many :sent_friendships, ->{ where status: false }, class_name: :Friendship, foreign_key: :invitor_id
  has_many :pending_friends, through: :sent_friendships, source: :invitee

  def friends
    (approved_friends.to_a + accepted_friends.to_a).compact
  end

  def find_friendship(user)
    inverse_friendships.where(invitor_id: user.id)
  end

  # def pending_friends
  #   friendships.map { |friendship| friendship.invitee unless friendship.status }.compact
  # end

  # def friend_requests
  #   inverse_friendships.map { |friendship| friendship.invitor unless friendship.status }.compact
  # end

  # def confirm_friend(invitor)
  #   friendship = inverse_friendships.where(invitor_id: invitor.id)
  #   friendship.update(status: true)
  # end

  def friend?(invitor)
    friends.include? invitor
  end
end
