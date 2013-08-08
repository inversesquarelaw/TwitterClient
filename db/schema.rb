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

ActiveRecord::Schema.define(:version => 20130808205336) do

  create_table "follows", :force => true do |t|
    t.string   "twitter_followee_id", :null => false
    t.string   "twitter_follower_id", :null => false
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "follows", ["twitter_followee_id", "twitter_follower_id"], :name => "index_follows_on_twitter_followee_id_and_twitter_follower_id", :unique => true
  add_index "follows", ["twitter_followee_id"], :name => "index_follows_on_twitter_followee_id"
  add_index "follows", ["twitter_follower_id"], :name => "index_follows_on_twitter_follower_id"

  create_table "statuses", :id => false, :force => true do |t|
    t.text     "body",              :null => false
    t.string   "twitter_status_id", :null => false
    t.string   "twitter_user_id",   :null => false
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "statuses", ["twitter_status_id"], :name => "index_statuses_on_twitter_status_id", :unique => true
  add_index "statuses", ["twitter_user_id"], :name => "index_statuses_on_twitter_user_id"

  create_table "users", :id => false, :force => true do |t|
    t.string   "twitter_user_id", :null => false
    t.string   "screen_name",     :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "users", ["screen_name"], :name => "index_users_on_screen_name", :unique => true
  add_index "users", ["twitter_user_id"], :name => "index_users_on_twitter_user_id", :unique => true

end
