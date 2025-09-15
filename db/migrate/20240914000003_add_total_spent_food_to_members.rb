class AddTotalSpentFoodToMembers < ActiveRecord::Migration[8.0]
  def change
    # Add missing total_spent_food field to complete member tracking
    # This field will track food purchases similar to total_spent_drinks
    add_column :members, :total_spent_food, :decimal, precision: 10, scale: 2, default: 0.0, null: false

    puts "Added total_spent_food field to members table"
  end

  def down
    remove_column :members, :total_spent_food
  end
end