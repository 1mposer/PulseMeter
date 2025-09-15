class AddNotNullConstraintsPhase1 < ActiveRecord::Migration[8.0]
  def up
    puts "Adding NOT NULL constraints - Phase 1 (Core fields)..."

    # Check for NULL values first and log warnings
    check_and_report_nulls

    # Start with highest-confidence fields (Sessions and Members)
    # Members first (likely cleanest data)
    puts "Adding NOT NULL to members table..."
    change_column_null :members, :name, false
    change_column_null :members, :email, false

    # Sessions core fields
    puts "Adding NOT NULL to sessions table..."
    change_column_null :sessions, :time_in, false
    change_column_null :sessions, :price_per_minute, false

    puts "Phase 1 NOT NULL constraints added successfully"
  end

  def down
    puts "Removing NOT NULL constraints - Phase 1..."

    change_column_null :sessions, :price_per_minute, true
    change_column_null :sessions, :time_in, true
    change_column_null :members, :email, true
    change_column_null :members, :name, true

    puts "Phase 1 rollback completed"
  end

  private

  def check_and_report_nulls
    # Check members table
    member_nulls = {
      name: execute("SELECT COUNT(*) FROM members WHERE name IS NULL").first[0],
      email: execute("SELECT COUNT(*) FROM members WHERE email IS NULL").first[0]
    }

    # Check sessions table
    session_nulls = {
      time_in: execute("SELECT COUNT(*) FROM sessions WHERE time_in IS NULL").first[0],
      price_per_minute: execute("SELECT COUNT(*) FROM sessions WHERE price_per_minute IS NULL").first[0]
    }

    puts "NULL value check results:"
    puts "  Members with NULL name: #{member_nulls[:name]}"
    puts "  Members with NULL email: #{member_nulls[:email]}"
    puts "  Sessions with NULL time_in: #{session_nulls[:time_in]}"
    puts "  Sessions with NULL price_per_minute: #{session_nulls[:price_per_minute]}"

    # Fail migration if any NULL values found
    total_nulls = member_nulls.values.sum + session_nulls.values.sum
    if total_nulls > 0
      raise "Migration aborted: #{total_nulls} NULL values found. Clean data first!"
    end
  end
end