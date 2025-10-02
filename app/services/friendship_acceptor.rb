class FriendshipAcceptor
  def initialize(friendship, current_user)
    @friendship = friendship
    @current_user = current_user
  end

  def call
    # nullチェックと認可を単一のプライベートメソッドで処理
    return false, '承認権限がありません' unless authorization_valid?

    # 更新を実行
    if @friendship.update(status: :accepted)
      return true, "#{@friendship.friend.username} さんと友達になりました"
    else
      return false, '承認に失敗しました'
    end
  end

  private

  def authorization_valid?
    @friendship.present? &&
      @friendship.pending? &&
      @friendship.friend_id == @current_user.id
  end
end