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

ActiveRecord::Schema.define(version: 20160427195249) do

  create_table "configuration_settings", force: true do |t|
    t.string   "job",        default: "{}"
    t.string   "client",     default: "{}"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "pool",       default: "{}"
  end

  create_table "faqs", force: true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "priority",   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "filesets", force: true do |t|
    t.string   "name"
    t.integer  "host_id"
    t.text     "exclude_directions"
    t.text     "include_directions"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "filesets", ["host_id"], name: "index_filesets_on_host_id", using: :btree

  create_table "hosts", force: true do |t|
    t.binary   "name",                       limit: 255,                 null: false
    t.binary   "fqdn",                       limit: 255,                 null: false
    t.integer  "port",                                                   null: false
    t.integer  "file_retention",                                         null: false
    t.integer  "job_retention",                                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password"
    t.boolean  "baculized",                              default: false, null: false
    t.datetime "baculized_at"
    t.integer  "status",                     limit: 1,   default: 0
    t.integer  "client_id"
    t.boolean  "verified",                               default: false
    t.datetime "verified_at"
    t.integer  "verifier_id"
    t.string   "job_retention_period_type"
    t.string   "file_retention_period_type"
    t.integer  "origin",                     limit: 1
    t.string   "email_recipients",                       default: "[]"
    t.integer  "quota",                      limit: 8,   default: 104857600
  end

  add_index "hosts", ["name"], name: "index_hosts_on_name", unique: true, length: {"name"=>128}, using: :btree

  create_table "invitations", force: true do |t|
    t.integer  "user_id"
    t.integer  "host_id"
    t.string   "verification_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invitations", ["user_id", "verification_code"], name: "index_invitations_on_user_id_and_verification_code", using: :btree

  create_table "job_templates", force: true do |t|
    t.string   "name",                                             null: false
    t.integer  "job_type",               limit: 1
    t.integer  "host_id"
    t.integer  "fileset_id"
    t.integer  "schedule_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "enabled",                          default: false
    t.binary   "restore_location"
    t.boolean  "baculized",                        default: false
    t.datetime "baculized_at"
    t.string   "client_before_run_file"
    t.string   "client_after_run_file"
  end

  create_table "ownerships", force: true do |t|
    t.integer  "user_id"
    t.integer  "host_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "schedule_runs", force: true do |t|
    t.integer  "schedule_id"
    t.integer  "level",       limit: 1
    t.string   "month"
    t.string   "day"
    t.string   "time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "schedule_runs", ["schedule_id"], name: "index_schedule_runs_on_schedule_id", using: :btree

  create_table "schedules", force: true do |t|
    t.string  "name"
    t.string  "runs"
    t.integer "host_id"
  end

  add_index "schedules", ["host_id"], name: "index_schedules_on_host_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "username",                                   null: false
    t.string   "email"
    t.integer  "user_type",        limit: 1,                 null: false
    t.boolean  "enabled",                    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "identifier"
    t.string   "password_hash"
    t.datetime "login_at"
    t.datetime "hosts_updated_at"
    t.string   "temp_hosts",                 default: "[]"
    t.string   "token"
    t.boolean  "moderator",                  default: false
  end

  add_index "users", ["identifier"], name: "index_users_on_identifier", using: :btree
  add_index "users", ["password_hash"], name: "index_users_on_password_hash", using: :btree
  add_index "users", ["token"], name: "index_arch.users_on_token", using: :btree

end
