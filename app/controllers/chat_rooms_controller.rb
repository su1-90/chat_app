class ChatRoomsController < ApplicationController
  class InvalidParticipantsError < StandardError
    attr_reader :invalid_ids

    def initialize(invalid_ids)
      @invalid_ids = invalid_ids
      super('友達ではないユーザーが含まれています')
    end
  end
  
  before_action :authenticate_user!

  def index
    @chat_room = ChatRoom.new
    @chat_rooms = list_chat_rooms(page_params)
    @friends = current_user.friends
    @selected_ids = []
  end

  def create
    friend_ids = valid_participant_ids!

    if friend_ids.empty?
      return render_index_with_error('チャット相手を選択してください')
    end

    room = 
      if friend_ids.size == 1
        friend = User.find(friend_ids.first)
        ChatRoom.find_or_create_dm!(current_user, friend)
      else
        member_ids = friend_ids + [current_user.id]
        ChatRoom.create_group!(name: room_name, member_ids: member_ids)
      end

    redirect_to room
  rescue InvalidParticipantsError => e
    render_index_with_error(e.message)    
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
    
    def render_index_with_error(message)
      @chat_room = ChatRoom.new
      @chat_room.errors.add(:base, message)

      @chat_rooms = list_chat_rooms(page_params)
      @friends = current_user.friends
      @selected_ids = requested_user_ids.map(&:to_i)

      render :index, status: :unprocessable_entity
    end

    def requested_user_ids
      params.permit(user_ids: [])[:user_ids] || []
    end

    def valid_participant_ids!
      friend_ids = current_user.friends.pluck(:id)
      requested = requested_user_ids.map(&:to_i).uniq

      valid, invalid = requested.partition { |id| valid_friend_id?(id, friend_ids) }
      raise InvalidParticipantsError, invalid if invalid.any?

      valid
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
