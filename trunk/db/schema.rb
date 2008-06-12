# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 15) do

  create_table "attachments", :force => true do |t|
    t.string  "type"
    t.string  "content_type"
    t.string  "filename"
    t.integer "size"
    t.integer "width"
    t.integer "height"
    t.integer "parent_id"
    t.integer "attachable_id"
    t.string  "attachable_type"
  end

  create_table "avatars", :force => true do |t|
    t.integer "user_id"
    t.string  "content_type"
    t.string  "filename"
    t.integer "size"
    t.integer "parent_id"
    t.string  "thumbnail"
    t.integer "width"
    t.integer "height"
  end

  create_table "categories", :force => true do |t|
    t.string   "title"
    t.integer  "parent_id"
    t.integer  "position"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "job_categories_jobs", :id => false, :force => true do |t|
    t.integer "job_id"
    t.integer "job_category_id"
  end

  create_table "job_events", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "place"
    t.datetime "time"
    t.datetime "closing_date_for_applications"
    t.integer  "author_id"
    t.integer  "last_editor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "job_links", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "target"
    t.integer  "position"
    t.integer  "author_id"
    t.integer  "last_editor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jobs", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.text     "company"
    t.text     "contact_data"
    t.datetime "published_at"
    t.datetime "published_until"
    t.string   "place"
    t.string   "qualification"
    t.boolean  "salary"
    t.date     "start_time"
    t.date     "end_time"
    t.integer  "author_id"
    t.integer  "last_editor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "news_items", :force => true do |t|
    t.string   "title"
    t.text     "text"
    t.datetime "published_at"
    t.datetime "published_until"
    t.integer  "author_id"
    t.integer  "last_editor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "category_id"
  end

  create_table "rights", :force => true do |t|
    t.string "name"
    t.string "controller"
    t.string "action"
  end

  create_table "rights_roles", :id => false, :force => true do |t|
    t.integer "right_id"
    t.integer "role_id"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
    t.string "title"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "type"
    t.integer  "role_id"
    t.string   "street"
    t.integer  "zip"
    t.string   "city"
    t.string   "phone"
    t.string   "homepage"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "home_street"
    t.integer  "home_zip"
    t.string   "home_city"
    t.string   "home_phone"
    t.string   "mobile"
    t.integer  "icq"
    t.date     "birthday"
    t.date     "application_date"
    t.datetime "opt_out_date"
    t.integer  "key_fs"
    t.integer  "key_wi"
    t.string   "study_course"
    t.boolean  "wi_ag_member"
    t.string   "institution_name"
    t.string   "contact_person_name"
  end

  add_index "users", ["login"], :name => "unique_login", :unique => true
  add_index "users", ["email"], :name => "unique_email", :unique => true

end
