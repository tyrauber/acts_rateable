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

ActiveRecord::Schema.define(:version => 20130520163820) do

  create_table "ar_rates", :force => true do |t|
    t.integer  "resource_id",                  :null => false
    t.string   "resource_type",                :null => false
    t.integer  "author_id",                    :null => false
    t.string   "author_type",                  :null => false
    t.integer  "value",         :default => 0
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "ar_rates", ["author_id", "author_type"], :name => "index_ar_rates_on_author_id_and_author_type"
  add_index "ar_rates", ["resource_id", "resource_type"], :name => "index_ar_rates_on_resource_id_and_resource_type"

  create_table "ar_ratings", :force => true do |t|
    t.integer  "resource_id",                    :null => false
    t.string   "resource_type",                  :null => false
    t.integer  "total",         :default => 0
    t.integer  "sum",           :default => 0
    t.decimal  "average",       :default => 0.0
    t.decimal  "estimate",      :default => 0.0
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "ar_ratings", ["resource_id", "resource_type"], :name => "index_ar_ratings_on_resource_id_and_resource_type"

  create_table "posts", :force => true do |t|
    t.string   "name"
    t.integer  "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.integer  "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
