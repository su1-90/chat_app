class Friendship < ApplicationRecord
  enum status: { pending: 0, accepted: 1, blocked: 2 }

  belongs_to :user
  belongs_to :friend, class_name: 'User'

  # 自分 vs 相手両方向の一意性を担保(オプションでモデルバリデーション)
  validates :user_id, uniqueness: { scope: :friend_id }
end
