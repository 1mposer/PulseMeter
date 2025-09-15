# Database Migration Status - Phase 2 Implementation

## ✅ CLEAN DATABASE RECREATION READY

**🚨 All migration conflicts resolved for clean DB setup:**
- **Fixed**: Removed duplicate `add_index :sessions, :table_id` (auto-created by add_reference)
- **Fixed**: Eliminated duplicate session column additions between migrations
- **Fixed**: Removed data cleanup (unnecessary for fresh DB)
- **Fixed**: Made table_id nullable to support sessions without table assignment

## 🚀 Recommended: Clean Database Setup

For the cleanest setup without any legacy data conflicts:

### Clean Setup Commands
```bash
# Complete clean database recreation
bin/rails db:drop db:create db:migrate db:seed

# Expected migrations to run:
# - 20250828120000_fix_drink_purchase_structure_and_add_missing_session_fields.rb
# - 20250828120001_create_food_purchases.rb
# - 20250828130000_add_default_price_per_minute_to_tables.rb
```

### Key Changes Applied

#### 0. Tables Default Pricing (NEW)
**Added Field:**
```ruby
t.decimal :default_price_per_minute, precision: 10, scale: 2, default: 0.5, null: false
```

**Purpose**: Enables `/scan/:tag_token/open` to work without requiring price_per_minute parameter.

**Behavior**:
- If `price_per_minute` provided in scan request → use that value
- If no `price_per_minute` provided → use `table.default_price_per_minute`

#### 1. DrinkPurchase Table Restructure
**Before:**
```ruby
t.integer "member_id", null: false  # ❌ Should be optional
t.decimal "amount"                  # ❌ Wrong field name
t.datetime "purchased_at"           # ❌ Unnecessary field
# Missing session_id, unit_price_at_sale, total_price
```

**After:**
```ruby
t.references :session, null: false, foreign_key: true
t.integer "member_id", null: true                     # ✅ Optional member
t.decimal :unit_price_at_sale, precision: 10, scale: 2, null: false
t.decimal :total_price, precision: 10, scale: 2, null: false
t.integer :quantity, null: false
```

#### 2. Sessions Table Enhancement  
**Added Fields:**
```ruby
t.references :table, null: true, foreign_key: true
t.references :tag, null: true, foreign_key: true  
t.string :opened_via
t.datetime :voided_at
t.text :void_reason
```

**Critical Constraint:**
```sql
-- Prevents multiple open sessions per table
CREATE UNIQUE INDEX index_sessions_on_table_single_open 
ON sessions (table_id, time_out) 
WHERE (time_out IS NULL AND voided_at IS NULL);
```

#### 3. FoodPurchase Table Creation
**New Table:** (mirrors DrinkPurchase structure)
```ruby
create_table :food_purchases do |t|
  t.references :session, null: false, foreign_key: true
  t.references :member, null: true, foreign_key: true  
  t.references :item, null: false, foreign_key: true
  t.integer :quantity, null: false
  t.decimal :unit_price_at_sale, precision: 10, scale: 2, null: false
  t.decimal :total_price, precision: 10, scale: 2, null: false
end
```

### Verification Commands

After running migrations, verify success:

```bash
# 1. Check schema version is updated
bin/rails runner "puts ActiveRecord::Migrator.current_version"
# Expected: 20250828120001 (or higher)

# 2. Verify single session constraint exists  
bin/rails runner "
puts ActiveRecord::Base.connection.index_exists?(
  :sessions, [:table_id, :time_out], 
  name: 'index_sessions_on_table_single_open'
) ? '✅ Constraint verified' : '❌ Missing constraint!'
"

# 3. Check table structures
bin/rails db:schema:dump
grep -A 10 "create_table.*food_purchases" db/schema.rb
grep -A 5 "index_sessions_on_table_single_open" db/schema.rb
```

### Rollback Strategy (If Needed)

```bash
# Rollback to previous state (emergency only)
bin/rails db:rollback STEP=2

# Or rollback to specific version  
bin/rails db:migrate VERSION=20250814153336
```

### Impact on Tests

**⚠️ Test Database Must Be Updated:**
```bash
RAILS_ENV=test bin/rails db:migrate
RAILS_ENV=test bin/rails db:test:prepare
```

**Expected Test Failures Before Migration:**
- DrinkPurchase model tests (missing session association)
- Session model tests (missing table/tag associations) 
- Purchase controller tests (missing endpoints)
- Serializer tests (outdated JSON structure)

**After Migration - All Tests Should Pass**

### Production Deployment Notes

**⚠️ For Production (Future):**
1. Backup database before migration
2. Run migrations during maintenance window
3. Verify constraint creation doesn't lock tables excessively
4. Test rollback procedure in staging first

---

**Status**: ❌ **Migrations Pending - Must Run Before Audit**  
**Last Updated**: 2025-08-28  
**Next Action**: Repository owner must run `bin/rails db:migrate`