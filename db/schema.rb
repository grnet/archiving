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

ActiveRecord::Schema.define(version: 20151122202041) do

  create_table "BaseFiles", primary_key: "BaseId", force: true do |t|
    t.integer "BaseJobId",           null: false
    t.integer "JobId",               null: false
    t.integer "FileId",    limit: 8, null: false
    t.integer "FileIndex"
  end

  add_index "BaseFiles", ["JobId"], name: "basefiles_jobid_idx", using: :btree

  create_table "CDImages", primary_key: "MediaId", force: true do |t|
    t.datetime "LastBurn", null: false
  end

  create_table "Client", primary_key: "ClientId", force: true do |t|
    t.binary  "Name",          limit: 255,             null: false
    t.binary  "Uname",         limit: 255,             null: false
    t.integer "AutoPrune",     limit: 1,   default: 0
    t.integer "FileRetention", limit: 8,   default: 0
    t.integer "JobRetention",  limit: 8,   default: 0
  end

  add_index "Client", ["Name"], name: "Name", unique: true, length: {"Name"=>128}, using: :btree

  create_table "Counters", id: false, force: true do |t|
    t.binary  "Counter",      limit: 255,             null: false
    t.integer "MinValue",                 default: 0
    t.integer "MaxValue",                 default: 0
    t.integer "CurrentValue",             default: 0
    t.binary  "WrapCounter",  limit: 255,             null: false
  end

  create_table "Device", primary_key: "DeviceId", force: true do |t|
    t.binary   "Name",                       limit: 255,             null: false
    t.integer  "MediaTypeId",                            default: 0
    t.integer  "StorageId",                              default: 0
    t.integer  "DevMounts",                              default: 0
    t.integer  "DevReadBytes",               limit: 8,   default: 0
    t.integer  "DevWriteBytes",              limit: 8,   default: 0
    t.integer  "DevReadBytesSinceCleaning",  limit: 8,   default: 0
    t.integer  "DevWriteBytesSinceCleaning", limit: 8,   default: 0
    t.integer  "DevReadTime",                limit: 8,   default: 0
    t.integer  "DevWriteTime",               limit: 8,   default: 0
    t.integer  "DevReadTimeSinceCleaning",   limit: 8,   default: 0
    t.integer  "DevWriteTimeSinceCleaning",  limit: 8,   default: 0
    t.datetime "CleaningDate"
    t.integer  "CleaningPeriod",             limit: 8,   default: 0
  end

  create_table "File", primary_key: "FileId", force: true do |t|
    t.integer "FileIndex",              default: 0
    t.integer "JobId",                              null: false
    t.integer "PathId",                             null: false
    t.integer "FilenameId",                         null: false
    t.integer "DeltaSeq",   limit: 2,   default: 0
    t.integer "MarkId",                 default: 0
    t.binary  "LStat",      limit: 255,             null: false
    t.binary  "MD5",        limit: 255
  end

  add_index "File", ["JobId", "PathId", "FilenameId"], name: "JobId_2", using: :btree
  add_index "File", ["JobId"], name: "JobId", using: :btree

  create_table "FileSet", primary_key: "FileSetId", force: true do |t|
    t.binary   "FileSet",    limit: 255, null: false
    t.binary   "MD5",        limit: 255
    t.datetime "CreateTime"
  end

  create_table "Filename", primary_key: "FilenameId", force: true do |t|
    t.binary "Name", null: false
  end

  add_index "Filename", ["Name"], name: "Name", length: {"Name"=>255}, using: :btree

  create_table "Job", primary_key: "JobId", force: true do |t|
    t.binary   "Job",             limit: 255,             null: false
    t.binary   "Name",            limit: 255,             null: false
    t.binary   "Type",            limit: 1,               null: false
    t.binary   "Level",           limit: 1,               null: false
    t.integer  "ClientId",                    default: 0
    t.binary   "JobStatus",       limit: 1,               null: false
    t.datetime "SchedTime"
    t.datetime "StartTime"
    t.datetime "EndTime"
    t.datetime "RealEndTime"
    t.integer  "JobTDate",        limit: 8,   default: 0
    t.integer  "VolSessionId",                default: 0
    t.integer  "VolSessionTime",              default: 0
    t.integer  "JobFiles",                    default: 0
    t.integer  "JobBytes",        limit: 8,   default: 0
    t.integer  "ReadBytes",       limit: 8,   default: 0
    t.integer  "JobErrors",                   default: 0
    t.integer  "JobMissingFiles",             default: 0
    t.integer  "PoolId",                      default: 0
    t.integer  "FileSetId",                   default: 0
    t.integer  "PriorJobId",                  default: 0
    t.integer  "PurgedFiles",     limit: 1,   default: 0
    t.integer  "HasBase",         limit: 1,   default: 0
    t.integer  "HasCache",        limit: 1,   default: 0
    t.integer  "Reviewed",        limit: 1,   default: 0
    t.binary   "Comment"
  end

  add_index "Job", ["Name"], name: "Name", length: {"Name"=>128}, using: :btree

  create_table "JobHisto", id: false, force: true do |t|
    t.integer  "JobId",                                   null: false
    t.binary   "Job",             limit: 255,             null: false
    t.binary   "Name",            limit: 255,             null: false
    t.binary   "Type",            limit: 1,               null: false
    t.binary   "Level",           limit: 1,               null: false
    t.integer  "ClientId",                    default: 0
    t.binary   "JobStatus",       limit: 1,               null: false
    t.datetime "SchedTime"
    t.datetime "StartTime"
    t.datetime "EndTime"
    t.datetime "RealEndTime"
    t.integer  "JobTDate",        limit: 8,   default: 0
    t.integer  "VolSessionId",                default: 0
    t.integer  "VolSessionTime",              default: 0
    t.integer  "JobFiles",                    default: 0
    t.integer  "JobBytes",        limit: 8,   default: 0
    t.integer  "ReadBytes",       limit: 8,   default: 0
    t.integer  "JobErrors",                   default: 0
    t.integer  "JobMissingFiles",             default: 0
    t.integer  "PoolId",                      default: 0
    t.integer  "FileSetId",                   default: 0
    t.integer  "PriorJobId",                  default: 0
    t.integer  "PurgedFiles",     limit: 1,   default: 0
    t.integer  "HasBase",         limit: 1,   default: 0
    t.integer  "HasCache",        limit: 1,   default: 0
    t.integer  "Reviewed",        limit: 1,   default: 0
    t.binary   "Comment"
  end

  add_index "JobHisto", ["JobId"], name: "JobId", using: :btree
  add_index "JobHisto", ["StartTime"], name: "StartTime", using: :btree

  create_table "JobMedia", primary_key: "JobMediaId", force: true do |t|
    t.integer "JobId",                  null: false
    t.integer "MediaId",                null: false
    t.integer "FirstIndex", default: 0
    t.integer "LastIndex",  default: 0
    t.integer "StartFile",  default: 0
    t.integer "EndFile",    default: 0
    t.integer "StartBlock", default: 0
    t.integer "EndBlock",   default: 0
    t.integer "VolIndex",   default: 0
  end

  add_index "JobMedia", ["JobId", "MediaId"], name: "JobId", using: :btree

  create_table "Location", primary_key: "LocationId", force: true do |t|
    t.binary  "Location", limit: 255,             null: false
    t.integer "Cost",                 default: 0
    t.integer "Enabled",  limit: 1
  end

  create_table "LocationLog", primary_key: "LocLogId", force: true do |t|
    t.datetime "Date"
    t.binary   "Comment",                            null: false
    t.integer  "MediaId",                default: 0
    t.integer  "LocationId",             default: 0
    t.string   "NewVolStatus", limit: 9,             null: false
    t.integer  "NewEnabled",   limit: 1
  end

  create_table "Log", primary_key: "LogId", force: true do |t|
    t.integer  "JobId",   default: 0
    t.datetime "Time"
    t.binary   "LogText",             null: false
  end

  add_index "Log", ["JobId"], name: "JobId", using: :btree

  create_table "Media", primary_key: "MediaId", force: true do |t|
    t.binary   "VolumeName",       limit: 255,             null: false
    t.integer  "Slot",                         default: 0
    t.integer  "PoolId",                       default: 0
    t.binary   "MediaType",        limit: 255,             null: false
    t.integer  "MediaTypeId",                  default: 0
    t.integer  "LabelType",        limit: 1,   default: 0
    t.datetime "FirstWritten"
    t.datetime "LastWritten"
    t.datetime "LabelDate"
    t.integer  "VolJobs",                      default: 0
    t.integer  "VolFiles",                     default: 0
    t.integer  "VolBlocks",                    default: 0
    t.integer  "VolMounts",                    default: 0
    t.integer  "VolBytes",         limit: 8,   default: 0
    t.integer  "VolParts",                     default: 0
    t.integer  "VolErrors",                    default: 0
    t.integer  "VolWrites",                    default: 0
    t.integer  "VolCapacityBytes", limit: 8,   default: 0
    t.string   "VolStatus",        limit: 9,               null: false
    t.integer  "Enabled",          limit: 1,   default: 1
    t.integer  "Recycle",          limit: 1,   default: 0
    t.integer  "ActionOnPurge",    limit: 1,   default: 0
    t.integer  "VolRetention",     limit: 8,   default: 0
    t.integer  "VolUseDuration",   limit: 8,   default: 0
    t.integer  "MaxVolJobs",                   default: 0
    t.integer  "MaxVolFiles",                  default: 0
    t.integer  "MaxVolBytes",      limit: 8,   default: 0
    t.integer  "InChanger",        limit: 1,   default: 0
    t.integer  "StorageId",                    default: 0
    t.integer  "DeviceId",                     default: 0
    t.integer  "MediaAddressing",  limit: 1,   default: 0
    t.integer  "VolReadTime",      limit: 8,   default: 0
    t.integer  "VolWriteTime",     limit: 8,   default: 0
    t.integer  "EndFile",                      default: 0
    t.integer  "EndBlock",                     default: 0
    t.integer  "LocationId",                   default: 0
    t.integer  "RecycleCount",                 default: 0
    t.datetime "InitialWrite"
    t.integer  "ScratchPoolId",                default: 0
    t.integer  "RecyclePoolId",                default: 0
    t.binary   "Comment"
  end

  add_index "Media", ["PoolId"], name: "PoolId", using: :btree
  add_index "Media", ["VolumeName"], name: "VolumeName", unique: true, length: {"VolumeName"=>128}, using: :btree

  create_table "MediaType", primary_key: "MediaTypeId", force: true do |t|
    t.binary  "MediaType", limit: 255,             null: false
    t.integer "ReadOnly",  limit: 1,   default: 0
  end

  create_table "Path", primary_key: "PathId", force: true do |t|
    t.binary "Path", null: false
  end

  add_index "Path", ["Path"], name: "Path", length: {"Path"=>255}, using: :btree

  create_table "PathHierarchy", primary_key: "PathId", force: true do |t|
    t.integer "PPathId", null: false
  end

  add_index "PathHierarchy", ["PPathId"], name: "pathhierarchy_ppathid", using: :btree

  create_table "PathVisibility", id: false, force: true do |t|
    t.integer "PathId",                       null: false
    t.integer "JobId",                        null: false
    t.integer "Size",   limit: 8, default: 0
    t.integer "Files",            default: 0
  end

  add_index "PathVisibility", ["JobId"], name: "pathvisibility_jobid", using: :btree

  create_table "Pool", primary_key: "PoolId", force: true do |t|
    t.binary  "Name",               limit: 255,             null: false
    t.integer "NumVols",                        default: 0
    t.integer "MaxVols",                        default: 0
    t.integer "UseOnce",            limit: 1,   default: 0
    t.integer "UseCatalog",         limit: 1,   default: 0
    t.integer "AcceptAnyVolume",    limit: 1,   default: 0
    t.integer "VolRetention",       limit: 8,   default: 0
    t.integer "VolUseDuration",     limit: 8,   default: 0
    t.integer "MaxVolJobs",                     default: 0
    t.integer "MaxVolFiles",                    default: 0
    t.integer "MaxVolBytes",        limit: 8,   default: 0
    t.integer "AutoPrune",          limit: 1,   default: 0
    t.integer "Recycle",            limit: 1,   default: 0
    t.integer "ActionOnPurge",      limit: 1,   default: 0
    t.string  "PoolType",           limit: 9,               null: false
    t.integer "LabelType",          limit: 1,   default: 0
    t.binary  "LabelFormat",        limit: 255
    t.integer "Enabled",            limit: 1,   default: 1
    t.integer "ScratchPoolId",                  default: 0
    t.integer "RecyclePoolId",                  default: 0
    t.integer "NextPoolId",                     default: 0
    t.integer "MigrationHighBytes", limit: 8,   default: 0
    t.integer "MigrationLowBytes",  limit: 8,   default: 0
    t.integer "MigrationTime",      limit: 8,   default: 0
  end

  add_index "Pool", ["Name"], name: "Name", unique: true, length: {"Name"=>128}, using: :btree

  create_table "RestoreObject", primary_key: "RestoreObjectId", force: true do |t|
    t.binary  "ObjectName",                                       null: false
    t.binary  "RestoreObject",     limit: 2147483647,             null: false
    t.binary  "PluginName",        limit: 255,                    null: false
    t.integer "ObjectLength",                         default: 0
    t.integer "ObjectFullLength",                     default: 0
    t.integer "ObjectIndex",                          default: 0
    t.integer "ObjectType",                           default: 0
    t.integer "FileIndex",                            default: 0
    t.integer "JobId",                                            null: false
    t.integer "ObjectCompression",                    default: 0
  end

  add_index "RestoreObject", ["JobId"], name: "JobId", using: :btree

  create_table "Status", primary_key: "JobStatus", force: true do |t|
    t.binary  "JobStatusLong"
    t.integer "Severity"
  end

  create_table "Storage", primary_key: "StorageId", force: true do |t|
    t.binary  "Name",        limit: 255,             null: false
    t.integer "AutoChanger", limit: 1,   default: 0
  end

  create_table "UnsavedFiles", primary_key: "UnsavedId", force: true do |t|
    t.integer "JobId",      null: false
    t.integer "PathId",     null: false
    t.integer "FilenameId", null: false
  end

  create_table "Version", id: false, force: true do |t|
    t.integer "VersionId", null: false
  end

  create_table "configuration_settings", force: true do |t|
    t.string   "job",        default: "{}"
    t.string   "client",     default: "{}"
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
  end

  add_index "hosts", ["name"], name: "index_hosts_on_name", unique: true, length: {"name"=>128}, using: :btree

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

  create_table "schedules", force: true do |t|
    t.string  "name"
    t.string  "runs"
    t.integer "host_id"
  end

  add_index "schedules", ["host_id"], name: "index_schedules_on_host_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "username",                             null: false
    t.string   "email"
    t.integer  "user_type",  limit: 1,                 null: false
    t.boolean  "enabled",              default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
