class RenameItemColumnsAndFixDataTypes < ActiveRecord::Migration[8.0]
  def change
    # Rename Item columns
    rename_column :items, :item_name, :name
    rename_column :items, :item_cost, :price
    
    # Fix Member data types
    change_column :members, :total_spent_sessions, :decimal, precision: 10, scale: 2, default: 0.0
    change_column :members, :total_spent_drinks, :decimal, precision: 10, scale: 2, default: 0.0
    
    # Add name column to members if it doesn't exist
    unless column_exists?(:members, :name)
      add_column :members, :name, :string
    end
  end
end

