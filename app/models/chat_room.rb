# == Schema Information
#
# Table name: chat_rooms
#
#  id            :bigint           not null, primary key
#  members_count :integer          default(0), not null
#  name          :string
#  room_type     :integer          default("dm"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_chat_rooms_on_room_type  (room_type)
#
class ChatRoom < ApplicationRecord
  MESSAGES_PER_PAGE = 50
  MIN_GROUP_MEMBERS = 3
  DM_MEMBERS_COUNT = 2

  enum :room_type, { dm: 0, group: 1 }, prefix: true

  has_many :messages, dependent: :destroy

  has_many :entries, dependent: :destroy
  has_many :users, through: :entries

  # 脱退による人数割れ（3人未満のグループ化）の検証は別PRで実装する。
  # 脱退機能が未実装のため、現時点では作成時のみバリデーションで検証する。
  validate :enough_group_members, on: :create

  scope :dm_between, ->(user_a, user_b) {
    room_type_dm
      .joins(:entries)
      .where(entries: { user_id: [user_a.id, user_b.id] }, members_count: DM_MEMBERS_COUNT)
      .group(:id)
      .having('COUNT(entries.id) = ?', DM_MEMBERS_COUNT)
  }

  def self.find_or_create_dm!(user_a, user_b)
    with_dm_lock(user_a, user_b) do
      room_id = dm_between(user_a, user_b).pick(:id)
      existing_room = find_by(id: room_id) if room_id
      existing_room || create_dm!(user_a, user_b)
    end
  end

  def self.with_dm_lock(user_a, user_b)
    id_1, id_2 = [user_a.id, user_b.id].sort
    transaction do
      connection.execute(
        sanitize_sql_array(["SELECT pg_advisory_xact_lock(?, ?)", id_1, id_2])
      )
      yield
    end
  end

  def self.create_dm!(user_a, user_b)
    room = create!(room_type: :dm)
    [user_a, user_b].each { |user| room.entries.create!(user: user) }
    room
  end
  private_class_method :create_dm!

  def self.create_group!(name:, member_ids:)
    ids = Array(member_ids).compact.uniq
    room = new(name: name, room_type: :group)
    ids.each { |id| room.entries.build(user_id: id) }
    room.save!
    room
  end

  def display_name_for(viewer)
    return name if name.present?

    partner = users.where.not(id: viewer.id).first
    partner&.username || partner&.email
  end

  def member?(user)
    entries.exists?(user_id: user.id)
  end

  def messages_for_display(page:)
    messages
      .includes(:user)
      .order(created_at: :asc)
      .page(page)
      .per(MESSAGES_PER_PAGE)
  end

  private

    def enough_group_members
      return unless room_type_group?
      return if entries.size >= MIN_GROUP_MEMBERS

      errors.add(:base, "グループには#{MIN_GROUP_MEMBERS}人以上のメンバーが必要です")
    end
end
