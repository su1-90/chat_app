# == Schema Information
#
# Table name: chat_rooms
#
#  id            :bigint           not null, primary key
#  members_count :integer          default(0), not null
#  name          :string
#  room_type     :integer          default("dm"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_chat_rooms_on_room_type  (room_type)
#
require 'rails_helper'

RSpec.describe ChatRoom, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
