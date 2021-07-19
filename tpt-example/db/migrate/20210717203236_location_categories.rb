class LocationCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :location_categories do |t|
      t.integer :category_id
      t.integer :location_id
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
    end
  end
end
