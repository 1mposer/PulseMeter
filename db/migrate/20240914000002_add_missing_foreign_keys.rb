class AddMissingForeignKeys < ActiveRecord::Migration[8.0]
  def change
    # First check for orphaned sessions that would break the foreign key
    puts "Checking for orphaned sessions..."
    orphaned_count = execute("
      SELECT COUNT(*) FROM sessions
      LEFT JOIN members ON sessions.membership_id = members.id
      WHERE sessions.membership_id IS NOT NULL AND members.id IS NULL
    ").first[0]

    if orphaned_count > 0
      puts "WARNING: #{orphaned_count} orphaned sessions found. Nullifying membership_id..."
      execute("
        UPDATE sessions
        SET membership_id = NULL
        WHERE membership_id IS NOT NULL
        AND membership_id NOT IN (SELECT id FROM members)
      ")
    else
      puts "No orphaned sessions found."
    end

    # Add the missing foreign key constraint
    add_foreign_key :sessions, :members, column: :membership_id, name: 'fk_sessions_membership_id'
    puts "Added foreign key constraint for sessions.membership_id → members.id"
  end

  def down
    remove_foreign_key :sessions, name: 'fk_sessions_membership_id'
  end
end