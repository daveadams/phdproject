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

ActiveRecord::Schema.define(:version => 20090909233507) do

  create_table "activity_logs", :force => true do |t|
    t.integer  "participant_id"
    t.string   "event"
    t.string   "controller"
    t.string   "action"
    t.text     "details"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "answers", :force => true do |t|
    t.integer  "question_id"
    t.text     "answer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sequence"
  end

  create_table "answers_participants", :id => false, :force => true do |t|
    t.integer "answer_id"
    t.integer "participant_id"
  end

  create_table "cash_transactions", :force => true do |t|
    t.integer  "participant_id"
    t.integer  "round"
    t.string   "transaction_type"
    t.decimal  "amount",           :precision => 8, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "correct_corrections", :force => true do |t|
    t.integer  "participant_id"
    t.integer  "round"
    t.integer  "correction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "corrected_texts", :force => true do |t|
    t.integer  "round"
    t.text     "corrected_text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "corrections", :force => true do |t|
    t.integer  "source_text_id"
    t.string   "error"
    t.string   "correction"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "error_context"
    t.string   "correction_context"
  end

  create_table "experiment_texts", :force => true do |t|
    t.string   "page_name"
    t.string   "text_key"
    t.text     "text"
    t.integer  "experimental_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "experimental_groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tutorial_text_group_id"
    t.decimal  "earnings",                 :precision => 8, :scale => 2, :default => 0.35
    t.integer  "tax_rate",                                               :default => 20
    t.decimal  "penalty_rate",             :precision => 8, :scale => 2, :default => 1.5
    t.integer  "rounds",                                                 :default => 20
    t.string   "shortname"
    t.text     "message"
    t.decimal  "audit_rate",               :precision => 8, :scale => 4, :default => 0.01
    t.integer  "survey_id"
    t.decimal  "noncompliance_audit_rate", :precision => 8, :scale => 4, :default => 0.02
    t.integer  "work_time_limit",                                        :default => 120
  end

  create_table "experimental_sessions", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_active",      :default => false
    t.string   "phase",          :default => "tutorial"
    t.integer  "round",          :default => 1
    t.datetime "started_at"
    t.datetime "ended_at"
    t.boolean  "is_complete",    :default => false
    t.boolean  "is_locked_down", :default => false
  end

  create_table "page_orders", :force => true do |t|
    t.string   "phase"
    t.integer  "experimental_group_id"
    t.text     "page_order"
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
    t.string   "phase"
    t.string   "page"
    t.integer  "round",                                                 :default => 1
    t.boolean  "tutorial_complete",                                     :default => false
    t.boolean  "experiment_complete",                                   :default => false
    t.boolean  "survey_complete",                                       :default => false
    t.boolean  "all_complete",                                          :default => false
    t.text     "reported_earnings"
    t.integer  "last_check",                                            :default => 0
    t.boolean  "audited",                                               :default => false
    t.boolean  "to_be_audited",                                         :default => false
    t.boolean  "audit_completed",                                       :default => false
    t.decimal  "tutorial_cash",           :precision => 8, :scale => 2, :default => 0.0
    t.datetime "work_load_time"
  end

  create_table "questions", :force => true do |t|
    t.text     "question"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "fill_in_the_blank", :default => false
    t.integer  "minimum",           :default => 0
    t.integer  "maximum",           :default => 100
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "source_texts", :force => true do |t|
    t.text     "errored_text"
    t.integer  "round"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_items", :force => true do |t|
    t.integer  "survey_page_id"
    t.integer  "question_id"
    t.integer  "sequence"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_pages", :force => true do |t|
    t.integer  "survey_id"
    t.integer  "sequence"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "depends_on_answer_id"
  end

  create_table "surveys", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tutorial_corrections", :id => false, :force => true do |t|
    t.integer "correction_id"
    t.integer "participant_id"
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
