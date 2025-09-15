class CreateDrinkPurchases < ActiveRecord::Migration[8.0]
  def change
    create_table :drink_purchases do |t|
      t.references :item, null: false, foreign_key: true
      t.decimal :amount
      t.datetime :purchased_at
      t.integer :quantity
      t.references :member, null: false, foreign_key: true

      t.timestamps
    end
  end
end
