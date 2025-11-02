module FriendshipsHelper
  # ここ修正
  def friendship_action(user, target_user)
    # すでに友達か？
    friendship = Friendship.find_by(user: user, friend: target_user) ||
                 Friendship.find_by(user: target_user, friend: user)

    return content_tag(:span, '友達') if friendship

    # 申請中か？
    request = FriendRequest.find_by(user: user, friend: target_user, status: :pending)
    return content_tag(:span, '申請中') if request

    # 相手から申請を受けているか？
    received_request = FriendRequest.find_by(user: target_user, friend: user, status: :pending)
    if received_request
      return button_to '承認する',
                       friend_request_path(received_request, status: :accepted),
                       method: :patch
    end

    # 申請拒否済みか？
    rejected_request = FriendRequest.find_by(user: user, friend: target_user, status: :rejected)
    return content_tag(:span, '申請拒否済み') if rejected_request

    # どの状態でもなければ「申請する」ボタン
    button_to '申請する',
              friend_requests_path(friend_id: target_user.id),
              method: :post
  end
end