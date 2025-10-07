# app/helpers/friendships_helper.rb
module FriendshipsHelper
  def friendship_action(user, target_user)
    status = user.friendship_status_with(target_user)
    friendship = user.sent_friendship_to(target_user) || user.received_friendship_from(target_user)

    case status
    when :pending
      content_tag(:span, '申請中')
    when :accepted
      content_tag(:span, '友達')
    when :blocked
      if friendship&.friend_id == current_user.id
        content_tag(:span, '申請拒否済み') +
          button_to("拒否解除", unblock_friendship_path(friendship), method: :delete, data: { turbo_confirm: "拒否を解除しますか？" })
      else
        content_tag(:span, '申請拒否されました')
      end
    
    else
      button_to '申請する',
                friendships_path(friend_id: target_user.id),
                method: :post
    end
  end
end
