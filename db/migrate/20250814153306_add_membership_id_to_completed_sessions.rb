class AddMembershipIdToCompletedSessions < ActiveRecord::Migration[8.0]
  def change
    add_column :completed_sessions, :membership_id, :integer
    add_index :completed_sessions, :membership_id
  end
end
