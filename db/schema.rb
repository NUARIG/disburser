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

ActiveRecord::Schema.define(version: 20170214145908) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

  create_table "disburser_request_details", force: :cascade do |t|
    t.integer  "disburser_request_id", null: false
    t.integer  "specimen_type_id",     null: false
    t.integer  "quantity",             null: false
    t.string   "volume"
    t.text     "comments"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "disburser_request_statuses", force: :cascade do |t|
    t.integer  "disburser_request_id", null: false
    t.string   "status_type",          null: false
    t.string   "status",               null: false
    t.integer  "user_id",              null: false
    t.text     "comments"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "disburser_request_votes", force: :cascade do |t|
    t.integer  "disburser_request_id",     null: false
    t.integer  "committee_member_user_id", null: false
    t.string   "vote",                     null: false
    t.text     "comments"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "disburser_requests", force: :cascade do |t|
    t.integer  "repository_id",          null: false
    t.integer  "submitter_id",           null: false
    t.string   "title",                  null: false
    t.string   "investigator",           null: false
    t.string   "irb_number",             null: false
    t.boolean  "feasibility"
    t.text     "methods_justifications", null: false
    t.text     "cohort_criteria",        null: false
    t.text     "data_for_cohort",        null: false
    t.string   "status",                 null: false
    t.string   "fulfillment_status",     null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "repositories", force: :cascade do |t|
    t.string   "name",             null: false
    t.string   "irb_template"
    t.string   "data_dictionary"
    t.text     "general_content"
    t.text     "data_content"
    t.text     "specimen_content"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.boolean  "public"
  end

  create_table "repository_users", force: :cascade do |t|
    t.integer  "repository_id",        null: false
    t.integer  "user_id",              null: false
    t.boolean  "administrator"
    t.boolean  "committee"
    t.boolean  "specimen_coordinator"
    t.boolean  "data_coordinator"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "specimen_types", force: :cascade do |t|
    t.integer  "repository_id", null: false
    t.string   "name",          null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                default: "", null: false
    t.string   "encrypted_password",   default: ""
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",        default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "username",                          null: false
    t.boolean  "system_administrator"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.index ["email"], name: "index_users_on_email", using: :btree
    t.index ["username"], name: "index_users_on_username", unique: true, using: :btree
  end

end
