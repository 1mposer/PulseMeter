# Ricochet Billing System - Architecture Overview

## Domain Model

The system models a billiard hall Point-of-Sale with the following core entities:

### Core Entities
- **Session**: Time-tracked table usage with per-minute pricing
- **Member**: Optional customer accounts with spending totals  
- **Table**: Physical billiard tables with NFC/QR tag mapping
- **Tag**: NFC/QR identifiers linked to specific tables
- **Item**: Product catalog (drinks + food) with category validation
- **DrinkPurchase/FoodPurchase**: Line items tied to sessions
- **CompletedSession**: Immutable archive of closed sessions

### Key Relationships
```
Table 1:N Tags 1:N Sessions 1:N Purchases N:1 Items
      1:N Sessions N:1 Members
```

## Architectural Principles

### 1. "Serializers Own JSON"
All API responses flow through dedicated serializer classes. Controllers **never** construct ad-hoc JSON hashes.

**✅ Good:**
```ruby
render json: SessionSerializer.new(@session).as_json
```

**❌ Bad:**
```ruby  
render json: { id: @session.id, status: "open" }
```

### 2. Money as Decimal
All monetary values use Rails `decimal` type with explicit precision for accuracy:
```ruby
t.decimal :price_per_minute, precision: 10, scale: 2
t.decimal :total_price, precision: 10, scale: 2
```

### 3. Immutable Archive Pattern
When sessions close, complete data snapshots are archived to `CompletedSession` including:
- All purchase line items in JSON receipt format
- Final calculated totals  
- Timestamp of closure
- Member association (if any)

### 4. Single Open Session Constraint
**Business Rule**: Only one session can be open per table at any time.

**Enforcement**: Database unique partial index + model validation:
```sql
CREATE UNIQUE INDEX index_sessions_on_table_single_open 
ON sessions (table_id, time_out) 
WHERE (time_out IS NULL AND voided_at IS NULL);
```

### 5. State Machine Integrity
Sessions follow strict state transitions:
- **open** → closed (via time_out)
- **open** → voided (admin action)  
- **closed** sessions are immutable
- Purchases only allowed on **open** sessions

## Security Considerations

### Data Protection
- No PII in seed data (audit_demo.rb contains only synthetic records)
- Secrets managed via Rails credentials (master.key never committed)
- Monetary calculations use precise decimal arithmetic

### Access Controls
- API-first design (no session cookies/authentication implemented yet)
- Input validation on all models with category guards
- Foreign key constraints enforce referential integrity

## Rounding & Tax Policy

### Duration Rounding
Session duration calculated with **ceiling rounding** to next minute:
```ruby
def duration_minutes
  return ((time_out - time_in) / 60).ceil
end
```

### Tax Handling
Currently tax_amount defaults to 0.00 in receipts. Tax calculation logic can be added to serializers without model changes.

## Performance Considerations

- Eager loading with `includes(:item)` on purchase queries
- Database indexes on foreign keys and search columns
- Immutable archive reduces load on active sessions table