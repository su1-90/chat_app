# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_01_05_095742) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "chat_rooms", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "entries", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "chat_room_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_room_id"], name: "index_entries_on_chat_room_id"
    t.index ["user_id", "chat_room_id"], name: "index_entries_on_user_id_and_chat_room_id", unique: true
    t.index ["user_id"], name: "index_entries_on_user_id"
  end

  create_table "friend_requests", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "friend_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["friend_id"], name: "index_friend_requests_on_friend_id"
    t.index ["user_id", "friend_id"], name: "index_friend_requests_on_user_id_and_friend_id", unique: true
    t.index ["user_id"], name: "index_friend_requests_on_user_id"
  end

  create_table "friendship_users", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "friendship_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["friendship_id"], name: "index_friendship_users_on_friendship_id"
    t.index ["user_id", "friendship_id"], name: "index_friendship_users_on_user_id_and_friendship_id", unique: true
    t.index ["user_id"], name: "index_friendship_users_on_user_id"
  end

  create_table "friendships", force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "chat_room_id", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_room_id"], name: "index_messages_on_chat_room_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username", default: "", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "entries", "chat_rooms"
  add_foreign_key "entries", "users"
  add_foreign_key "friend_requests", "users"
  add_foreign_key "friend_requests", "users", column: "friend_id"
  add_foreign_key "friendship_users", "friendships"
  add_foreign_key "friendship_users", "users"
  add_foreign_key "messages", "chat_rooms"
  add_foreign_key "messages", "users"
end
