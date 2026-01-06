# == Schema Information
#
# Table name: friendships
#
#  id         :bigint           not null, primary key
#  status     :integer          default("active"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Friendship, type: :model do
  let(:user)   { User.create!(username: "Alice", email: "a@example.com", password: "password") }
  let(:friend) { User.create!(username: "Bob",   email: "b@example.com", password: "password") }

  it "同じ組み合わせは重複できない" do
    Friendship.create!(user: user, friend: friend)
    duplicate = Friendship.new(user: user, friend: friend)
    expect(duplicate).not_to be_valid
  end

  it "自分自身には申請できない" do
    self_friendship = Friendship.new(user: user, friend: user)
    expect(self_friendship).not_to be_valid
  end
end
