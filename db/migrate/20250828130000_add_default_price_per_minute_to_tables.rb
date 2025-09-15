class AddDefaultPricePerMinuteToTables < ActiveRecord::Migration[8.0]
  def change
    add_column :tables, :default_price_per_minute, :decimal, 
               precision: 10, scale: 2, default: 0.5, null: false
  end
end