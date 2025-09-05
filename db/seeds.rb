# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding database..."

# Create Members
members_data = [
  { name: "John Smith", email: "john.smith@example.com" },
  { name: "Sarah Johnson", email: "sarah.johnson@example.com" },
  { name: "Michael Brown", email: "michael.brown@example.com" },
  { name: "Emily Davis", email: "emily.davis@example.com" },
  { name: "David Wilson", email: "david.wilson@example.com" },
  { name: "Lisa Anderson", email: "lisa.anderson@example.com" },
  { name: "Robert Taylor", email: "robert.taylor@example.com" },
  { name: "Jennifer Martinez", email: "jennifer.martinez@example.com" },
  { name: "Christopher Garcia", email: "christopher.garcia@example.com" },
  { name: "Amanda Rodriguez", email: "amanda.rodriguez@example.com" },
  { name: "James Lee", email: "james.lee@example.com" },
  { name: "Michelle White", email: "michelle.white@example.com" }
]

members_data.each do |member_attrs|
  member = Member.find_or_create_by!(email: member_attrs[:email]) do |m|
    m.name = member_attrs[:name]
    m.total_spent_sessions = 0.0
    m.total_spent_drinks = 0.0
  end
  
  # Update existing members to ensure they have the required fields
  member.update!(
    name: member_attrs[:name],
    total_spent_sessions: member.total_spent_sessions || 0.0,
    total_spent_drinks: member.total_spent_drinks || 0.0
  )
end

puts "Created/updated #{Member.count} members"

# Create Items (categorized as drink or food only)
items_data = [
  { name: "Espresso", price: 3.50, stock_quantity: 100, category: "drink" },
  { name: "Cappuccino", price: 4.75, stock_quantity: 80, category: "drink" },
  { name: "Latte", price: 4.50, stock_quantity: 90, category: "drink" },
  { name: "Americano", price: 3.25, stock_quantity: 120, category: "drink" },
  { name: "Green Tea", price: 2.75, stock_quantity: 60, category: "drink" },
  { name: "Chai Latte", price: 4.25, stock_quantity: 70, category: "drink" },
  { name: "Hot Chocolate", price: 4.00, stock_quantity: 50, category: "drink" },
  { name: "Orange Juice", price: 3.00, stock_quantity: 40, category: "drink" },
  { name: "Bottled Water", price: 2.00, stock_quantity: 200, category: "drink" },
  { name: "Energy Drink", price: 3.75, stock_quantity: 30, category: "drink" },
  { name: "Club Sandwich", price: 12.50, stock_quantity: 25, category: "food" },
  { name: "Caesar Salad", price: 10.75, stock_quantity: 20, category: "food" },
  { name: "French Fries", price: 6.50, stock_quantity: 40, category: "food" },
  { name: "Chicken Wings", price: 14.00, stock_quantity: 30, category: "food" },
  { name: "Nachos", price: 8.75, stock_quantity: 35, category: "food" }
]

items_data.each do |item_attrs|
  # Safety guard: only process items with valid categories
  category = item_attrs[:category]
  unless %w[drink food].include?(category)
    puts "⚠️ Skipping item '#{item_attrs[:name]}' with invalid category '#{category}'"
    next
  end
  
  item = Item.find_or_create_by!(name: item_attrs[:name]) do |i|
    i.price = item_attrs[:price]
    i.stock_quantity = item_attrs[:stock_quantity]
    i.category = item_attrs[:category]
  end
  
  # Update existing items to ensure they have the required fields
  item.update!(
    price: item_attrs[:price],
    stock_quantity: item_attrs[:stock_quantity],
    category: item_attrs[:category]
  )
end

puts "Created/updated #{Item.count} items"

puts "Database seeding completed successfully!"
puts "Total Members: #{Member.count}"
puts "Total Items: #{Item.count}"

# Create demo tables and tags for testing
demo_tables = [
  { name: "Table 1", default_price_per_minute: 0.5 },
  { name: "Table 2", default_price_per_minute: 0.75 },
  { name: "Table 3", default_price_per_minute: 0.5 }
]

demo_tables.each_with_index do |table_attrs, index|
  table = Table.find_or_create_by!(name: table_attrs[:name]) do |t|
    t.active = true
    t.default_price_per_minute = table_attrs[:default_price_per_minute]
  end
  
  # Update existing tables to ensure they have the default price
  table.update!(
    active: true,
    default_price_per_minute: table_attrs[:default_price_per_minute]
  )
  
  # Create a tag for each table
  tag_token = "DEMO_TAG_#{sprintf('%03d', index + 1)}"
  tag = Tag.find_or_create_by!(token: tag_token, table: table) do |t|
    t.active = true
  end
  
  tag.update!(active: true)
end

puts "Created/updated #{Table.count} tables and #{Tag.count} tags"
