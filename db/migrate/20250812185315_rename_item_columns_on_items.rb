class RenameItemColumnsOnItems < ActiveRecord::Migration[7.1]
  def change
    if column_exists?(:items, :item_name)
      rename_column :items, :item_name, :name
    end

    if column_exists?(:items, :item_cost)
      rename_column :items, :item_cost, :price
      change_column :items, :price, :decimal, precision: 10, scale: 2
    end
  end
end
