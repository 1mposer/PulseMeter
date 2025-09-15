class AddNotNullConstraintsPhase2 < ActiveRecord::Migration[8.0]
  def up
    puts "Adding NOT NULL constraints - Phase 2 (Items and CompletedSessions)..."

    # Check for NULL values first
    check_and_report_nulls

    # Items table - critical business data
    puts "Adding NOT NULL to items table..."
    change_column_null :items, :name, false
    change_column_null :items, :price, false
    change_column_null :items, :stock_quantity, false
    change_column_null :items, :category, false

    # CompletedSessions table - archival data integrity
    puts "Adding NOT NULL to completed_sessions table..."
    change_column_null :completed_sessions, :session_id, false
    change_column_null :completed_sessions, :duration_mins, false
    change_column_null :completed_sessions, :total_cost, false
    change_column_null :completed_sessions, :receipt, false
    change_column_null :completed_sessions, :completed_at, false
    change_column_null :completed_sessions, :price_per_min, false

    puts "Phase 2 NOT NULL constraints added successfully"
  end

  def down
    puts "Removing NOT NULL constraints - Phase 2..."

    # CompletedSessions rollback
    change_column_null :completed_sessions, :price_per_min, true
    change_column_null :completed_sessions, :completed_at, true
    change_column_null :completed_sessions, :receipt, true
    change_column_null :completed_sessions, :total_cost, true
    change_column_null :completed_sessions, :duration_mins, true
    change_column_null :completed_sessions, :session_id, true

    # Items rollback
    change_column_null :items, :category, true
    change_column_null :items, :stock_quantity, true
    change_column_null :items, :price, true
    change_column_null :items, :name, true

    puts "Phase 2 rollback completed"
  end

  private

  def check_and_report_nulls
    # Check items table
    item_nulls = {
      name: execute("SELECT COUNT(*) FROM items WHERE name IS NULL").first[0],
      price: execute("SELECT COUNT(*) FROM items WHERE price IS NULL").first[0],
      stock_quantity: execute("SELECT COUNT(*) FROM items WHERE stock_quantity IS NULL").first[0],
      category: execute("SELECT COUNT(*) FROM items WHERE category IS NULL").first[0]
    }

    # Check completed_sessions table
    cs_nulls = {
      session_id: execute("SELECT COUNT(*) FROM completed_sessions WHERE session_id IS NULL").first[0],
      duration_mins: execute("SELECT COUNT(*) FROM completed_sessions WHERE duration_mins IS NULL").first[0],
      total_cost: execute("SELECT COUNT(*) FROM completed_sessions WHERE total_cost IS NULL").first[0],
      receipt: execute("SELECT COUNT(*) FROM completed_sessions WHERE receipt IS NULL").first[0],
      completed_at: execute("SELECT COUNT(*) FROM completed_sessions WHERE completed_at IS NULL").first[0],
      price_per_min: execute("SELECT COUNT(*) FROM completed_sessions WHERE price_per_min IS NULL").first[0]
    }

    puts "NULL value check results:"
    puts "  Items with NULL values: #{item_nulls.values.sum}"
    puts "  CompletedSessions with NULL values: #{cs_nulls.values.sum}"

    # Fail migration if any NULL values found
    total_nulls = item_nulls.values.sum + cs_nulls.values.sum
    if total_nulls > 0
      raise "Migration aborted: #{total_nulls} NULL values found. Clean data first!"
    end
  end
end