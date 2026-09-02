# == Schema Information
#
# Table name: friendship_users
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  friendship_id :bigint           not null
#  user_id       :bigint           not null
#
# Indexes
#
#  index_friendship_users_on_friendship_id              (friendship_id)
#  index_friendship_users_on_user_id                    (user_id)
#  index_friendship_users_on_user_id_and_friendship_id  (user_id,friendship_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (friendship_id => friendships.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe FriendshipUser, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
