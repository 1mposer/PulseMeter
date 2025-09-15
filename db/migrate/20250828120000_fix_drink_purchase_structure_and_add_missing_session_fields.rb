class FixDrinkPurchaseStructureAndAddMissingSessionFields < ActiveRecord::Migration[8.0]
  def change
    # Fix DrinkPurchase table structure
    change_table :drink_purchases do |t|
      t.references :session, null: false, foreign_key: true
      t.change :member_id, :integer, null: true  # Make member optional
      t.decimal :unit_price_at_sale, precision: 10, scale: 2, null: false
      t.decimal :total_price, precision: 10, scale: 2, null: false
      t.remove :amount
      t.remove :purchased_at
      t.change :quantity, :integer, null: false
    end

    # Session fields already added by previous migration (20250815120003)

    # Add constraint to prevent multiple open sessions per table
    add_index :sessions, [:table_id, :time_out], 
              where: "time_out IS NULL AND voided_at IS NULL",
              unique: true, 
              name: "index_sessions_on_table_single_open"
  end
end