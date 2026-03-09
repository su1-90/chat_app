class ChatRoomsController < ApplicationController
  before_action :authenticate_user!

  def index
    inputs = index_inputs

    @chat_room = ChatRoom.new
    @chat_rooms = list_chat_rooms(inputs)
  end

  def create
    inputs = create_inputs

    if inputs[:partner_id]
      partner_id = inputs[:partner_id]

      return redirect_to(chat_rooms_path, alert: '相手が見つかりません') unless User.exists?(partner_id)

      room = 
        ChatRoom.dm_between(current_user.id, partner_id).first ||
        create_dm_room!(partner_id)

      redirect_to room
      return
    else
      @chat_room = ChatRoom.new(chat_room_params)

      if @chat_room.save
        @chat_room.entries.create!(user: current_user)
        redirect_to @chat_room, flash: { notice: 'チャットルームを作成しました' }
      else
        @chat_rooms = list_chat_rooms(index_inputs)
        flash.now[:alert] = 'チャットルームを作成できませんでした'
        render :index, status: :unprocessable_entity
      end
    end

  end

  def show
    inputs = show_inputs

    @chat_room = ChatRoom.find(inputs[:id])

    raise ActiveRecord::RecordNotFound unless @chat_room.member?(current_user)

    @messages = @chat_room.messages_for_display(page: inputs[:page])
    @message = @chat_room.messages.build(user: current_user)
  end

  private
    def index_inputs
      p = params.permit(:page)
      { page: normalize_page(p[:page]) }
    end
    
    def list_chat_rooms(inputs)
      current_user.chat_rooms
                  .order(created_at: :desc)
                  .page(inputs[:page])
                  .per(ChatRoom::MESSAGES_PER_PAGE)
    end
    
    def create_inputs
      p = params.permit(:partner_id)
      partner_id = p[:partner_id].to_i
      { partner_id: (partner_id.positive? && partner_id != current_user.id) ? partner_id : nil }
    end

    def create_dm_room!(partner_id)
      ChatRoom.transaction do
        room = ChatRoom.create!
        room.entries.create!(user_id: current_user.id)
        room.entries.create!(user_id: partner_id)
        room
      end
    end

    def chat_room_params
      params.require(:chat_room).permit(:name)
    end
    
    def show_inputs
      p = params.permit(:id, :page)
      
      { id: p[:id], page: normalize_page(p[:page]) }
    end
    
    def normalize_page(raw)
      n = raw.to_i
      [n, 1].max
    end
    
end