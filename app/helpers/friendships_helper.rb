# app/helpers/friendships_helper.rb
module FriendshipsHelper
  def friendship_action(user, target_user)
    status = user.friendship_status_with(target_user)

    case status
    when :pending
      content_tag(:span, '申請中')
    when :accepted
      content_tag(:span, '友達')
    when :blocked
      content_tag(:span, '申請拒否済み')
    else
      button_to '申請する',
                friendships_path(friend_id: target_user.id),
                method: :post
    end
  end
end
