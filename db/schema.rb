# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090814181709) do

  create_table "experimental_groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tutorial_text_group_id"
  end

  create_table "experimental_sessions", :force => true do |t|
    t.string   "name"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.integer  "experiment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "experiments", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participants", :force => true do |t|
    t.string   "participant_number"
    t.datetime "first_login"
    t.datetime "last_access"
    t.boolean  "is_active"
    t.integer  "experimental_session_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "experimental_group_id"
  end

  create_table "tutorial_text_groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tutorial_texts", :force => true do |t|
    t.string   "page_name"
    t.string   "text_key"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tutorial_text_group_id"
  end

end
