class ChatRoomsController < ApplicationController
  before_action :authenticate_user!

  def index
    @chat_room = ChatRoom.new
    @chat_rooms = list_chat_rooms(page_params)

    @friends = current_user.friends
  end

  def create
    participant_ids = valid_participant_ids
    participant_ids << current_user.id

    room = ChatRoom.find_or_create_between_room!(
      participant_ids,
      name: room_name
    )

    redirect_to room
  end

  def show
    inputs = show_params
    @chat_room = ChatRoom.find(inputs[:id])

    raise ActiveRecord::RecordNotFound unless @chat_room.member?(current_user)

    @messages = @chat_room.messages_for_display(page: inputs[:page])
    @message = @chat_room.messages.build(user: current_user)
  end


  private

    def page_params
      p = params.permit(:page)
      { page: normalize_page(p[:page]) }
    end
    
    def list_chat_rooms(inputs)
      current_user.chat_rooms
                  .order(created_at: :desc)
                  .page(inputs[:page])
                  .per(ChatRoom::MESSAGES_PER_PAGE)
    end
    
    def requested_user_ids
      params.permit(user_ids: [])[:user_ids] || []
    end

    def valid_participant_ids
      friend_ids = current_user.friends.pluck(:id)

      requested_user_ids
        .map(&:to_i)
        .select do |id|
          valid_friend_id?(id, friend_ids)
        end
    end

    def valid_friend_id?(id, friend_ids)
      id.positive? && friend_ids.include?(id)
    end

    def room_name
      params.permit(chat_room: [:name]).dig(:chat_room, :name)
    end

    def show_params
      p = params.permit(:id, :page)
      
      { id: p[:id], page: normalize_page(p[:page]) }
    end
    
    def normalize_page(raw)
      n = raw.to_i
      [n, 1].max
    end
end