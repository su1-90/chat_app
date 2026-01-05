# == Schema Information
#
# Table name: messages
#
#  id           :bigint           not null, primary key
#  user_id      :bigint           not null
#  chat_room_id :bigint           not null
#  body         :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
require 'rails_helper'

RSpec.describe Message, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
