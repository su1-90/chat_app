# == Schema Information
#
# Table name: friendship_users
#
#  id            :bigint           not null, primary key
#  user_id       :bigint           not null
#  friendship_id :bigint           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require 'rails_helper'

RSpec.describe FriendshipUser, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
