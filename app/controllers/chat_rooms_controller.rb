class ChatRoomsController < ApplicationController
  before_action :authenticate_user!

  def index
    @chat_room = ChatRoom.new
    @chat_rooms = list_chat_rooms(page_params)

    @friends = current_user.friends
  end

  def create
    partner_id = member_id_params[:partner_id]
    
    if partner_id
      all_user_ids = [current_user.id, partner_id]

      room = 
        ChatRoom.between_users(all_user_ids).take ||
        create_room!([partner_id])

      redirect_to room
      return
    else
      user_ids = member_id_params[:user_ids]
      all_user_ids = [current_user.id] + user_ids

      room = 
        ChatRoom.between_users(all_user_ids).take ||
        create_room!(user_ids, name: chat_room_params[:name])
      
      redirect_to room, flash: { notice: 'チャットルームを作成しました' }

    end
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
    
    def member_id_params
      p = params.permit(:partner_id, user_ids: [])

      partner_id = p[:partner_id].to_i
      user_ids = (p[:user_ids] || []).map(&:to_i)
                                    .select { |id| id.positive? && id != current_user.id }

      { 
        partner_id: (partner_id if partner_id.positive? && partner_id != current_user.id),
        user_ids: user_ids
      }
    end

    def create_room!(user_ids, name: nil)
      ChatRoom.transaction do
        all_user_ids = ([current_user.id] + user_ids).sort
        room_id = ChatRoom.between_users(all_user_ids).pick(:id)
        existing_room = ChatRoom.lock.find_by(id: room_id) if room_id
        return existing_room if existing_room
        
        room = ChatRoom.create!(name: name)

        room.entries.create!(user_id: current_user.id)

        user_ids.each do |user_id|
          room.entries.create!(user_id: user_id)
        end

        room
      end
    end

    def chat_room_params
      params.require(:chat_room).permit(:name)
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