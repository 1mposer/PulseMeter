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

ActiveRecord::Schema[8.0].define(version: 2025_08_28_130000) do
  create_table "completed_sessions", force: :cascade do |t|
    t.integer "session_id"
    t.integer "duration_mins"
    t.float "price_per_min"
    t.text "receipt"
    t.datetime "completed_at"
    t.float "total_cost"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "membership_id"
    t.integer "table_id"
    t.index ["membership_id"], name: "index_completed_sessions_on_membership_id"
    t.index ["table_id"], name: "index_completed_sessions_on_table_id"
  end

  create_table "drink_purchases", force: :cascade do |t|
    t.integer "item_id", null: false
    t.integer "quantity", null: false
    t.integer "member_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "session_id", null: false
    t.decimal "unit_price_at_sale", precision: 10, scale: 2, null: false
    t.decimal "total_price", precision: 10, scale: 2, null: false
    t.index ["item_id"], name: "index_drink_purchases_on_item_id"
    t.index ["member_id"], name: "index_drink_purchases_on_member_id"
    t.index ["session_id"], name: "index_drink_purchases_on_session_id"
  end

  create_table "food_purchases", force: :cascade do |t|
    t.integer "session_id", null: false
    t.integer "member_id"
    t.integer "item_id", null: false
    t.integer "quantity", null: false
    t.decimal "unit_price_at_sale", precision: 10, scale: 2, null: false
    t.decimal "total_price", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_food_purchases_on_item_id"
    t.index ["member_id"], name: "index_food_purchases_on_member_id"
    t.index ["session_id", "item_id"], name: "index_food_purchases_on_session_id_and_item_id"
    t.index ["session_id"], name: "index_food_purchases_on_session_id"
  end

  create_table "items", force: :cascade do |t|
    t.integer "item_id"
    t.string "name"
    t.decimal "price"
    t.integer "stock_quantity"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "members", force: :cascade do |t|
    t.string "email"
    t.decimal "total_spent_sessions", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "total_spent_drinks", precision: 10, scale: 2, default: "0.0"
    t.string "name"
    t.index ["email"], name: "index_members_on_email_unique", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "time_in"
    t.datetime "time_out"
    t.integer "membership_id"
    t.decimal "price_per_minute"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "table_id"
    t.integer "tag_id"
    t.string "opened_via"
    t.datetime "voided_at"
    t.text "void_reason"
    t.index ["table_id", "time_out"], name: "index_sessions_on_table_single_open", unique: true, where: "time_out IS NULL AND voided_at IS NULL"
    t.index ["table_id"], name: "index_sessions_on_table_id"
    t.index ["tag_id"], name: "index_sessions_on_tag_id"
  end

  create_table "tables", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "default_price_per_minute", precision: 10, scale: 2, default: "0.5", null: false
    t.index ["name"], name: "index_tables_on_name_unique", unique: true
  end

  create_table "tags", force: :cascade do |t|
    t.string "token", null: false
    t.integer "table_id", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["table_id"], name: "index_tags_on_table_id"
    t.index ["token"], name: "index_tags_on_token", unique: true
  end

  add_foreign_key "drink_purchases", "items"
  add_foreign_key "drink_purchases", "members"
  add_foreign_key "drink_purchases", "sessions"
  add_foreign_key "food_purchases", "items"
  add_foreign_key "food_purchases", "members"
  add_foreign_key "food_purchases", "sessions"
  add_foreign_key "sessions", "tables"
  add_foreign_key "sessions", "tags"
  add_foreign_key "tags", "tables"
end
