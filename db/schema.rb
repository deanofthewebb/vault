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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140915154058) do

  create_table "cb_employees", force: true do |t|
    t.string   "full_name"
    t.string   "employee_id"
    t.string   "network_name"
    t.string   "job_title"
    t.boolean  "is_manager"
    t.string   "email"
    t.text     "manager"
    t.text     "coworker"
    t.text     "subordinates"
    t.text     "additional_members"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cb_employees", ["full_name", "employee_id"], name: "index_cb_employees_on_full_name_and_employee_id", unique: true

  create_table "secret_files", force: true do |t|
    t.string   "file_name"
    t.string   "environment"
    t.string   "role"
    t.string   "secret_key"
    t.string   "login"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "secret_files", ["file_name", "environment"], name: "index_secret_files_on_file_name_and_environment", unique: true

  create_table "secret_links", force: true do |t|
    t.string   "username"
    t.string   "added_users"
    t.boolean  "blessed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "secret_links", ["username", "added_users"], name: "index_secret_links_on_username_and_added_users", unique: true

  create_table "users", force: true do |t|
    t.string   "login",               default: "", null: false
    t.string   "encrypted_password",  default: "", null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["login"], name: "index_users_on_login", unique: true

end
