class AddTableIdToCompletedSessions < ActiveRecord::Migration[8.0]
  def change
    add_column :completed_sessions, :table_id, :integer
    add_index :completed_sessions, :table_id
  end
end
