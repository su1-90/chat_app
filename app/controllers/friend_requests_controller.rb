class FriendRequestsController < ApplicationController
  before_action :authenticate_user!
  def create
    friend = User.find(params[:friend_id])
    
    return redirect_to(users_path, alert: '自分には申請できません') if friend == current_user
    return redirect_to(users_path, alert: 'すでに友達です') if current_user.friend_with?(friend)

    # 相手→自分の申請がpendingなら二重を作らない
    reverse = FriendRequest.find_by(user: friend, friend: current_user)
    if reverse&.pending?
      return redirect_to(users_path, alert: '相手から申請が届いています')
    end

    request = 
      current_user.friend_requests.find_or_initialize_by(friend: friend)

    # すでに申請中なら何もしない（二重送信防止）
    if request.persisted? && request.pending?
      return redirect_to users_path, alert: 'すでに申請済みです'
    end

    # 履歴は残しつつ、再申請は同一レコードを pending に戻す
    # accepted / rejected / nil（新規）いずれでも pending にする
    request.status = :pending

    if request.save
      redirect_to users_path, notice: '友達申請を送信しました'
    else
      redirect_to users_path, alert: request.errors.full_messages.to_sentence
    end
  end

  def update
    @friend_request = FriendRequest.find(params[:id])

    action = params[:status]&.to_sym

    case action
    when :accepted
      # 受け取った人だけが承認できる
      return redirect_to(users_path, alert: '権限がありません') unless @friend_request.friend == current_user

      raise ActiveRecord::RecordInvalid unless @friend_request.friend == current_user
      
      accept_request!
      redirect_to users_path, notice: '友達になりました'

    when :rejected
      return redirect_to(users_path, alert: '権限がありません') unless @friend_request.friend == current_user

      @friend_request.update!(status: :rejected)
      redirect_to users_path, notice: '友達申請を拒否しました'

    when :pending
      # 再申請=送った人だけが pending にできる
      return redirect_to(users_path, alert: '権限がありません') unless @friend_request.user == current_user

      @friend_request.update!(status: :pending)
      redirect_to users_path, notice: '申請を再開しました'

    else
      redirect_to users_path, alert: '不正な操作です'
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
