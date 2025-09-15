class BackfillMemberTotals < ActiveRecord::Migration[8.0]
  def up
    puts "Backfilling member totals from existing purchase data..."

    # Calculate correct totals for all existing members
    Member.find_each do |member|
      drinks_total = member.drink_purchases.sum(:total_price)
      food_total = member.food_purchases.sum(:total_price)
      sessions_total = member.sessions.where.not(time_out: nil).sum do |session|
        session.grand_total || 0
      end

      # Update member totals using update_columns to bypass callbacks
      member.update_columns(
        total_spent_drinks: drinks_total,
        total_spent_food: food_total,
        total_spent_sessions: sessions_total
      )

      puts "Member #{member.id}: drinks=$#{drinks_total}, food=$#{food_total}, sessions=$#{sessions_total}"
    end

    puts "Member totals backfill completed successfully"
  end

  def down
    puts "Resetting all member totals to 0..."

    # Reset all totals to 0
    Member.update_all(
      total_spent_drinks: 0.0,
      total_spent_food: 0.0,
      total_spent_sessions: 0.0
    )

    puts "Member totals reset completed"
  end
end