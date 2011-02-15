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

ActiveRecord::Schema.define(:version => 20110215150702) do

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.string   "body",           :limit => 3000
    t.string   "slug"
    t.datetime "published_at"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "likes_count",                    :default => 0
    t.integer  "comments_count",                 :default => 0
    t.integer  "votes_count",                    :default => 0
    t.integer  "parent_id"
    t.integer  "position",                       :default => 0
    t.integer  "post_id"
  end

  add_index "pages", ["comments_count"], :name => "index_pages_on_comments_count"
  add_index "pages", ["likes_count"], :name => "index_pages_on_likes_count"
  add_index "pages", ["parent_id"], :name => "index_pages_on_parent_id"
  add_index "pages", ["post_id"], :name => "index_pages_on_post_id"
  add_index "pages", ["slug"], :name => "index_pages_on_slug"
  add_index "pages", ["votes_count"], :name => "index_pages_on_votes_count"

end
