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

ActiveRecord::Schema.define(:version => 20130826093104) do

  create_table "articles", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.string   "author"
    t.datetime "published_at"
    t.integer  "photo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "imaginable_crops", :force => true do |t|
    t.integer "image_id"
    t.string  "crop"
    t.integer "x"
    t.integer "y"
    t.integer "w"
  end

  add_index "imaginable_crops", ["id", "crop"], :name => "index_imaginable_crops_on_id_and_crop"

  create_table "imaginable_images", :force => true do |t|
    t.string  "uuid"
    t.string  "token"
    t.integer "width"
    t.integer "height"
  end

  add_index "imaginable_images", ["uuid"], :name => "index_imaginable_images_on_uuid", :unique => true

end
