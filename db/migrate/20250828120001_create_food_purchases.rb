class CreateFoodPurchases < ActiveRecord::Migration[8.0]
  def change
    create_table :food_purchases do |t|
      t.references :session, null: false, foreign_key: true
      t.references :member, null: true, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.decimal :unit_price_at_sale, precision: 10, scale: 2, null: false
      t.decimal :total_price, precision: 10, scale: 2, null: false

      t.timestamps
    end

    add_index :food_purchases, [:session_id, :item_id]
  end
end