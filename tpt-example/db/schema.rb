# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_07_17_203236) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "tablefunc"

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "location_categories", force: :cascade do |t|
    t.integer "category_id"
    t.integer "location_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "locations", force: :cascade do |t|
    t.integer "campaign_id"
    t.string "name"
    t.text "notes"
    t.bigint "place_id"
    t.string "address"
    t.decimal "lat"
    t.decimal "lng"
    t.integer "position"
    t.boolean "is_active"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "market_id"
    t.text "available_here"
    t.integer "market_position"
    t.string "formatted_addresses", array: true
    t.string "addresses", array: true
    t.boolean "is_drive_thru"
    t.string "static_map"
    t.index ["addresses"], name: "index_locations_on_addresses"
    t.index ["formatted_addresses"], name: "index_locations_on_formatted_addresses"
  end

  create_table "markets", force: :cascade do |t|
    t.string "name"
    t.integer "region_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "position"
  end

  create_table "order_line_items", force: :cascade do |t|
    t.integer "order_id"
    t.bigint "product_id"
    t.string "title"
    t.integer "quantity"
    t.decimal "price"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["order_id", "product_id"], name: "index_order_line_items_on_order_id_and_product_id"
    t.index ["order_id"], name: "index_order_line_items_on_order_id"
    t.index ["product_id"], name: "index_order_line_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "order_id"
    t.integer "order_number"
    t.bigint "customer_id"
    t.integer "stop_id"
    t.datetime "sh_created_at"
    t.datetime "sh_updated_at"
    t.decimal "total"
    t.string "fulfillment_status"
    t.datetime "scanned_date"
    t.datetime "cancelled_at"
    t.string "financial_status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "location_id"
    t.integer "sh_location_id"
    t.integer "sh_stop_id"
    t.string "sh_location"
    t.string "sh_address"
    t.string "sh_coordinates"
    t.string "sh_date_time"
    t.string "order_type"
    t.integer "user_id"
    t.boolean "sh_fulfill", default: false
    t.boolean "is_mismatched", default: false
    t.integer "canceled_order_id"
    t.integer "migrated_order_id"
    t.text "scanned_coordinates"
    t.integer "scanned_from_location_id"
    t.string "template_version"
    t.index ["location_id"], name: "index_orders_on_location_id"
    t.index ["order_id"], name: "index_orders_on_order_id", unique: true
    t.index ["order_number"], name: "index_orders_on_order_number"
    t.index ["stop_id"], name: "index_orders_on_stop_id"
  end

  create_table "products", force: :cascade do |t|
    t.bigint "product_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.integer "qty"
    t.integer "product_type", default: 0
    t.bigint "variant_id"
    t.string "image_url"
    t.decimal "price"
    t.string "title"
  end

  create_table "region_tours", force: :cascade do |t|
    t.integer "tour_id"
    t.integer "region_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "regions", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "route_date_stops", force: :cascade do |t|
    t.integer "route_date_id"
    t.integer "stop_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "route_dates", force: :cascade do |t|
    t.integer "route_id"
    t.date "date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.integer "status"
    t.bigint "stop_id"
  end

  create_table "routes", force: :cascade do |t|
    t.string "name"
    t.boolean "is_active"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "color_name"
    t.string "color"
    t.bigint "tour_id"
  end

  create_table "stops", force: :cascade do |t|
    t.integer "location_id"
    t.date "date"
    t.string "timezone"
    t.string "loc_id"
    t.string "hurry_up_before"
    t.string "sold_out_before"
    t.integer "max_boxes"
    t.integer "sold_boxes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "date_type"
    t.date "repeat_until"
    t.time "start_time"
    t.time "end_time"
    t.string "klaviyo_remider_1_id"
    t.string "klaviyo_remider_2_id"
    t.string "klaviyo_remider_3_id"
    t.string "contact_name"
    t.string "contact_phone"
    t.string "contact_email"
    t.text "notes"
    t.integer "status", default: 1
    t.integer "target_boxes"
    t.index ["date"], name: "index_stops_on_date"
  end

  create_table "tours", force: :cascade do |t|
    t.string "name"
    t.string "friendly_name"
    t.string "season"
    t.date "start_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

end
