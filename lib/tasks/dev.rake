# lib/tasks/dev.rake
namespace :dev do
  desc "Reset + seed deterministic data for development"
  task prime: :environment do
    # 1) DDL safety: quick existence check for required tables
    %w[members sessions items tables tags].each do |t|
      abort("Missing table: #{t}") unless ActiveRecord::Base.connection.table_exists?(t)
    end

    puts ">> Wiping data (idempotent)..."

    # Delete in dependency order to avoid foreign key violations
    DrinkPurchase.delete_all
    FoodPurchase.delete_all
    Session.delete_all
    Tag.delete_all
    Table.delete_all
    Item.delete_all
    Member.delete_all

    # Reset SQLite auto-increment sequences for deterministic IDs
    %w[members sessions items tables tags drink_purchases food_purchases].each do |table|
      ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name = '#{table}'")
    end

    puts ">> Seeding members..."
    members = (1..3).map do |i|
      Member.create!(
        id: i,
        name: "Member #{i}",
        email: "member#{i}@example.com",
        total_spent_sessions: 0.0,
        total_spent_drinks: 0.0,
        total_spent_food: 0.0
      )
    end

    puts ">> Seeding tables..."
    table = Table.create!(
      id: 1,
      name: "Table 1",
      active: true,
      default_price_per_minute: 1.50
    )

    puts ">> Seeding tags..."
    tag = Tag.create!(
      id: 1,
      token: "DEMO_001",
      table: table,
      active: true
    )

    puts ">> Seeding items (drinks + food)..."
    drinks = [
      {id: 101, name: "Water",  category: "drink", price: 5.00, stock_quantity: 50},
      {id: 102, name: "Soda",   category: "drink", price: 8.00, stock_quantity: 30},
      {id: 103, name: "Coffee", category: "drink", price: 12.00, stock_quantity: 20},
    ]
    foods = [
      {id: 201, name: "Burger",   category: "food", price: 25.00, stock_quantity: 15},
      {id: 202, name: "Pizza",    category: "food", price: 35.00, stock_quantity: 10},
      {id: 203, name: "Sandwich", category: "food", price: 18.00, stock_quantity: 25},
    ]
    (drinks + foods).each { |attrs| Item.create!(attrs) }

    puts ">> Seeding sessions (open + closed)..."
    # Open session (used for golden capture)
    open_session = Session.create!(
      id: 301,
      membership_id: members.first.id,
      table_id: table.id,
      tag_id: tag.id,
      time_in: Time.current - 30.minutes,
      time_out: nil,
      price_per_minute: 1.50,
      opened_via: "nfc"
    )

    # A few closed sessions for realism
    (302..304).each do |sid|
      Session.create!(
        id: sid,
        membership_id: members.sample.id,
        table_id: table.id,
        tag_id: tag.id,
        time_in: Time.current - 3.hours,
        time_out: Time.current - 2.hours,
        price_per_minute: 1.50,
        opened_via: "nfc"
      )
    end

    puts "✅ dev:prime complete."
    puts "   Open session ID: #{open_session.id}"
    puts "   Member ID: #{members.first.id}"
    puts "   Drink item ID: #{Item.drinks.first.id}"
    puts "   Food item ID: #{Item.food.first.id}"
  end
end