class AddTotalSpentDrinksToMembers < ActiveRecord::Migration[8.0]
  def change
    add_column :members, :total_spent_drinks, :float
  end
end
