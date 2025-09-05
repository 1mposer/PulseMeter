# Audit Demo Seed Data
# This file contains synthetic data for external audit purposes only
# No PII or real customer data included

puts "🔍 Creating Audit Demo Data..."

# Create demo table and tag
table = Table.find_or_create_by!(name: "Audit Table 1") do |t|
  t.active = true
  t.default_price_per_minute = 0.5
end

# Ensure existing table has default price
table.update!(default_price_per_minute: 0.5) if table.default_price_per_minute.nil?

tag = Tag.find_or_create_by!(token: "AUDIT_TAG_1", table: table) do |t|
  t.active = true
end

# Create demo items for both categories (matching main seeds)
drink_item = Item.find_or_create_by!(name: "Espresso", category: "drink") do |i|
  i.price = 3.50
  i.stock_quantity = 100
end

food_item = Item.find_or_create_by!(name: "Club Sandwich", category: "food") do |i|
  i.price = 12.50
  i.stock_quantity = 25
end

# Create demo member
member = Member.find_or_create_by!(email: "audit.demo@example.com") do |m|
  m.name = "Audit Demo Member"
  m.total_spent_sessions = 0.0
  m.total_spent_drinks = 0.0
end

puts "✅ Seeded successfully:"
puts "  - Table: #{table.name} (ID: #{table.id})"
puts "  - Tag: #{tag.token} -> Table #{table.name}"
puts "  - Items: #{Item.drinks.count} drinks, #{Item.food.count} food items"
puts "  - Members: #{Member.count} demo member(s)"
puts ""
puts "🧪 Ready for audit demo workflow:"
puts "  1. Scan tag #{tag.token} to open session"
puts "  2. Add drink/food purchases"  
puts "  3. Close session to generate receipt"