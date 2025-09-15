# Clean Database Setup - Zero-Error Migration

## ✅ FIXED: Migration Issues Resolved

**All duplicate column/index issues have been eliminated for clean DB recreation.**

### Issues Fixed:
- ✅ Removed duplicate `add_index :sessions, :table_id` (auto-created by add_reference)
- ✅ Removed duplicate session column additions
- ✅ Removed data cleanup (unnecessary for clean DB)
- ✅ Ensured migration sequence works from scratch

## 🚀 Clean Setup Commands

Run these commands for a complete clean database setup:

```bash
# 1. Drop and recreate database
bin/rails db:drop db:create db:migrate

# 2. Load audit demo data
bin/rails runner db/seeds/audit_demo.rb

# 3. Verify schema integrity
bin/rails runner "
puts '=== SCHEMA VERIFICATION ==='
puts 'Sessions columns:'
p ActiveRecord::Base.connection.columns(:sessions).map(&:name)
puts 'Single session constraint:'
p ActiveRecord::Base.connection.index_exists?(:sessions, [:table_id, :time_out], name: 'index_sessions_on_table_single_open')
puts 'DrinkPurchase columns:'
p ActiveRecord::Base.connection.columns(:drink_purchases).map(&:name)
puts 'FoodPurchase table exists:'
p ActiveRecord::Base.connection.table_exists?(:food_purchases)
"
```

## 📋 Expected Schema Structure

After migration, the schema should include:

### Sessions Table
- `id`, `time_in`, `time_out`, `membership_id`, `price_per_minute` (original)
- `table_id` (nullable, with FK and index)
- `tag_id` (nullable, with FK)  
- `opened_via` (string, nullable)
- `voided_at` (datetime, nullable)
- `void_reason` (text, nullable)

### Indexes
- `index_sessions_on_table_single_open` (unique partial index)
- Standard FK indexes on `table_id`, `tag_id`

### DrinkPurchase Table
- `session_id` (not null, with FK)
- `member_id` (nullable, with FK)
- `item_id` (not null, with FK)
- `quantity` (integer, not null)
- `unit_price_at_sale` (decimal 10,2, not null)
- `total_price` (decimal 10,2, not null)

### FoodPurchase Table  
- Same structure as DrinkPurchase

## 🧪 Test Commands

After setup, test the complete workflow:

```bash
# Test audit demo workflow - Case 1: Use table default price
curl -X POST localhost:3000/scan/AUDIT_TAG_1/open \
  -H "Content-Type: application/json"

# Test audit demo workflow - Case 2: Override with custom price
curl -X POST localhost:3000/scan/AUDIT_TAG_1/open \
  -H "Content-Type: application/json" \
  -d '{"price_per_minute": 0.75}'

# Add purchases (use session_id from above and actual item IDs)
# Get item IDs: bin/rails runner "puts Item.drinks.first.id, Item.food.first.id"
curl -X POST localhost:3000/sessions/{session_id}/drink_purchases \
  -H "Content-Type: application/json" \
  -d '{"item_id": 1, "quantity": 2}'

# Close session  
curl -X PATCH localhost:3000/sessions/{session_id} \
  -H "Content-Type: application/json" \
  -d '{"session": {"time_out": "2025-08-28T15:30:00Z"}}'
```

All commands should execute without errors.