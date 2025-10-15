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

  it "status のデフォルトは pending" do
    friendship = Friendship.create!(user: user, friend: friend)
    expect(friendship.status).to eq("pending")
  end

  context "statas の遷移" do
    it "pending -> accepted に変更できる" do
      friendship = Friendship.create!(user: user, friend: friend)
      friendship.accepted!
      expect(friendship.status).to eq("accepted")
      expect(friendship).to be_accepted
    end

    it "pending -> blocked に変更できる" do
      friendship = Friendship.create!(user: user, friend: friend)
      friendship.blocked!
      expect(friendship.status).to eq("blocked")
      expect(friendship).to be_blocked
    end
  end
end
