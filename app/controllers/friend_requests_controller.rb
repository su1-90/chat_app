class FriendRequestsController < ApplicationController
  before_action :authenticate_user!
  def create
    friend = User.find(params[:friend_id])

    # すでに友達なら申請させない
    if current_user.friendship_with(friend).present?
      return redirect_to users_path, alert: "すでに友達です"
    end

    request = current_user.friend_requests.find_or_initialize_by(friend: friend)

    # accepted / rejected なら再申請として pending に戻す
    if request.accepted? || request.rejected?
      request.status = :pending
    end

    if request.save
      redirect_to users_path, notice: "友達申請を送信しました"
    else
      redirect_to users_path, alert: request.errors.full_messages.to_sentence
    end
  end

  def update
    @friend_request = FriendRequest.find(params[:id])

    case params[:status]
    when "accepted"
      # 受け取った人だけが承認できる
      return redirect_to(users_path, alert: "権限がありません") unless @friend_request.friend == current_user

      accept_request!
      redirect_to users_path, notice: "友達になりました"

    when "rejected"
      return redirect_to(users_path, alert: "権限がありません") unless @friend_request.friend == current_user

      @friend_request.update!(status: :rejected)
      redirect_to users_path, notice: "友達申請を拒否しました"

    when "pending"
      # 再申請=送った人だけが pending にできる
      return redirect_to(users_path, alert: "権限がありません") unless @friend_request.user == current_user

      @friend_request.update!(status: :pending)
      redirect_to users_path, notice: "申請を再開しました"

    else
      redirect_to users_path, alert: "不正な操作です"
    end
  end

  private

  def accept_request!
    ActiveRecord::Base.transaction do
      friendship = Friendship.create!(status: :active)

      FriendshipUser.create!(user: @friend_request.user, friendship: friendship)
      FriendshipUser.create!(user: @friend_request.friend, friendship: friendship)

      @friend_request.update!(status: :accepted)
    end
  end
end
