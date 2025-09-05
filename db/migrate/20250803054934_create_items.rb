class CreateItems < ActiveRecord::Migration[8.0]
  def change
    create_table :items do |t|
      t.integer :item_id
      t.string :item_name
      t.decimal :item_cost
      t.integer :stock_quantity
      t.string :category

      t.timestamps
    end
  end
end
