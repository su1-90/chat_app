class FriendshipsController < ApplicationController
  before_action :authenticate_user!

  def index
    @sent_requests = current_user.friendships.pending
    @received_requests = current_user.inverse_friendships.pending
  end

  def create
    friend = User.find_by(id: params[:friend_id])
    # user が見つからなかった場合のハンドリング
    unless friend
      redirect_to users_path, alert: "申請相手のユーザーが見つかりません。"
      return
    end

    friendship = current_user.friendships.build(friend: friend, status: :pending)
    if friendship.save
      redirect_to users_path, notice: "#{friend.username} に申請を送りました"
    else
      redirect_to users_path, alert: friendship.errors.full_messages.to_sentence
    end
  end

  # 拒否 or 解除: 送受信いずれの申請/関係でも自分が当事者なら削除可
  def destroy
    friendship = Friendship.find_by(id: params[:id])
    unless friendship && [friendship.user_id, friendship.friend_id].include?(current_user.id)
      redirect_back fallback_location: friendships_path, alert: "操作権限がありません。"
      return
    end

    label = 
      if friendship.accepted?
        "友達を解除しました"
      elsif friendship.pending?
        if friendship.user_id == current_user.id
          "送信した申請をキャンセルしました"
        else
          "受信した申請を拒否しました"
        end
      else
        "関係を削除しました"
      end

      if friendship.destroy
        redirect_back fallback_location: friendships_path, notice: label
      else
        redirect_back fallback_location: friendhips_path, alert: "削除に失敗しました。"
      end
  end

  # 友達リストの表示
  def accepted
    # &:friend → do |f| f.friend end の省略記法.
    # Friendshipオブジェクトから関連づけられた「friend(User)」だけを取り出す。=> 「承認済みFriendshipの相手ユーザー」だけを集めた配列になる
    @friends = current_user.friendships.accepted.includes(:friend).map(&:friend)
  end

  def update
    friendship = Friendship.find_by(id: params[:id])
    result, message = FriendshipAcceptor.new(friendship, current_user).call

    if result
      redirect_to friendships_path, notice: message
    else
      redirect_back fallback_location: friendships_path, alert: message
    end
  end

end