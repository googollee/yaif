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

ActiveRecord::Schema.define(:version => 20111031022100) do

  create_table "actions", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "http_type"
    t.string   "http_method"
    t.string   "params"
    t.string   "target"
    t.text     "body"
    t.integer  "service_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "actions", ["service_id"], :name => "index_actions_on_service_id"

  create_table "services", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "icon"
    t.string   "auth_type"
    t.text     "auth_data"
    t.text     "helper"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tasks", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.integer  "trigger_id"
    t.text     "trigger_params"
    t.integer  "action_id"
    t.text     "action_params"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tasks", ["action_id"], :name => "index_tasks_on_action_id"
  add_index "tasks", ["trigger_id"], :name => "index_tasks_on_trigger_id"
  add_index "tasks", ["user_id"], :name => "index_tasks_on_user_id"

  create_table "triggers", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "http_type"
    t.string   "http_method"
    t.string   "params"
    t.string   "source"
    t.string   "out_keys"
    t.text     "content_to_hash"
    t.integer  "service_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "triggers", ["service_id"], :name => "index_triggers_on_service_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
