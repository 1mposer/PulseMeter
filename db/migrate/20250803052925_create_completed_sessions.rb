class CreateCompletedSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :completed_sessions do |t|
      t.integer :session_id
      t.integer :duration_mins
      t.float :price_per_min
      t.text :receipt
      t.datetime :completed_at
      t.float :total_cost

      t.timestamps
    end
  end
end
