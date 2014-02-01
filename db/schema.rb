# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140129181046) do

  create_table "portfolio_traders", :force => true do |t|
    t.integer  "portfolio_week_id"
    t.integer  "trader_account"
    t.float    "start_value"
    t.float    "end_value"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "portfolio_weeks", :force => true do |t|
    t.integer  "portfolio_id"
    t.float    "profit"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "portfolios", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.float    "rating"
    t.string   "comment"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "traders", :force => true do |t|
    t.string   "brocker"
    t.string   "name"
    t.integer  "account"
    t.datetime "registration_date"
    t.integer  "pamm2"
    t.integer  "tp"
    t.integer  "min_value"
    t.integer  "investor_percent"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "traders", ["account"], :name => "index_traders_on_account", :unique => true

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",           :default => false
    t.string   "first_name"
    t.string   "second_name"
    t.string   "sex"
    t.datetime "date_of_birth"
    t.string   "country"
    t.string   "city"
    t.datetime "start_inv_date"
    t.string   "social_vk"
    t.string   "social_fb"
    t.string   "about_info"
  end

  add_index "users", ["name"], :name => "index_users_on_name", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end
