# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180415164700) do

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "histories", force: :cascade do |t|
    t.decimal "cash"
    t.decimal "stocks"
    t.integer "stocks_count"
    t.decimal "options"
    t.decimal "options_count"
    t.decimal "total"
    t.datetime "snapshot_date"
    t.integer "portfolio_id"
    t.decimal "daily_dividend"
    t.datetime "daily_dividend_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["snapshot_date"], name: "index_histories_on_snapshot_date"
  end

  create_table "portfolios", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.decimal "cash", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "group_id"
  end

  create_table "stocks", force: :cascade do |t|
    t.integer "portfolio_id"
    t.decimal "purchase_price", precision: 10, scale: 2
    t.decimal "quantity", precision: 10, scale: 2
    t.string "symbol"
    t.string "name"
    t.string "purchase_date"
    t.decimal "strike", precision: 10, scale: 2
    t.decimal "price"
    t.string "as_of"
    t.string "expiration_date"
    t.string "stock_option"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "change"
    t.decimal "daily_dividend"
    t.datetime "daily_dividend_date"
  end

end
