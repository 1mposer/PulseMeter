# External Audit Scope - Security & Code Quality Review

## Audit Checklist

### 🔐 Security Review
- [ ] **Secrets Management**: No credentials tracked in git history
- [ ] **Input Validation**: All user inputs validated at model level
- [ ] **SQL Injection**: ActiveRecord used consistently, no raw SQL
- [ ] **Mass Assignment**: Strong parameters enforced in controllers
- [ ] **Authorization**: API endpoints properly scoped (future: add authentication)
- [ ] **Error Handling**: No sensitive data leaked in error responses
- [ ] **Dependencies**: Check for vulnerable gems via `bundle audit`

### 💾 Data Model Integrity
- [ ] **Money Handling**: All currency fields use decimal precision (10,2)
- [ ] **Foreign Keys**: Database constraints prevent orphaned records
- [ ] **Unique Constraints**: Single open session per table enforced at DB level
- [ ] **State Transitions**: Session state machine prevents invalid transitions
- [ ] **Immutable Archive**: CompletedSession creates tamper-proof snapshots
- [ ] **Category Validation**: Items properly categorized as drink/food only

### 🎛️ Controllers & Serializers
- [ ] **Serializer Pattern**: No ad-hoc JSON construction in controllers
- [ ] **Error Serialization**: Consistent error format via ErrorSerializer  
- [ ] **Purchase Validation**: Only open sessions allow new purchases
- [ ] **Category Guards**: DrinkPurchase/FoodPurchase enforce item type
- [ ] **Price Snapshot**: unit_price_at_sale captures pricing at purchase time
- [ ] **HTTP Methods**: RESTful conventions followed (POST for creates, PATCH for updates)

### 🔄 Business Logic & State Machine
- [ ] **Session Lifecycle**: open → closed/voided state transitions work correctly
- [ ] **Duration Calculation**: Time rounding policy is consistent and tested
- [ ] **Total Calculations**: table_total + drinks_total + food_total = grand_total
- [ ] **Voiding Logic**: Voided sessions return $0.00 grand_total
- [ ] **Archive Trigger**: CompletedSession created exactly once on close

### 💰 Purchase & Inventory Flow
- [ ] **Stock Updates**: Item quantities decremented on purchase
- [ ] **Member Totals**: Spending rolled up to member.total_spent_* fields
- [ ] **Purchase Endpoints**: POST /sessions/:id/drink_purchases and food_purchases
- [ ] **Item Availability**: Out-of-stock items handled gracefully
- [ ] **Purchase History**: Full audit trail in DrinkPurchase/FoodPurchase tables

### 🧪 Rounding & Tax Policy
- [ ] **Duration Rounding**: Sessions round **up** to next minute (.ceil method)
- [ ] **Money Formatting**: All currency displayed as 2-decimal strings
- [ ] **Tax Calculation**: Placeholder at 0.00, extensible for future tax logic
- [ ] **Receipt Accuracy**: Serialized totals match manual calculations

### 🧪 Test Coverage & CI
- [ ] **Model Tests**: Validations, associations, business logic methods
- [ ] **Controller Tests**: HTTP responses, error handling, serialization
- [ ] **Integration Tests**: Full workflow from session open → purchase → close
- [ ] **Static Analysis**: brakeman, rubocop, bundle audit passing
- [ ] **Test Database**: Separate test DB, no production data contamination

## Expected Outputs

### ✅ Passing Static Checks
```bash
$ bundle exec brakeman -A
# 0 security warnings

$ bundle exec bundle audit check --update  
# No known vulnerabilities found

$ bundle exec rubocop -A
# No offenses detected

$ RAILS_ENV=test bin/rails db:test:prepare && bundle exec rspec
# All tests passing, >90% coverage
```

### 📊 Audit Demo Workflow
The auditor should be able to execute:
1. `bin/rails db:reset && bin/rails runner db/seeds/audit_demo.rb`
2. `POST /scan/AUDIT_TAG_1/open` → creates session
3. `POST /sessions/{id}/drink_purchases` with `{item_id: drink.id, quantity: 2}`
4. `PATCH /sessions/{id}` with `time_out` → closes session & creates receipt
5. Verify receipt JSON contains drinks array, correct totals, immutable archive

## Out of Scope

- **Authentication/Authorization**: API currently open, security layer planned for Phase 3
- **Frontend/UI**: JSON API only, no HTML views to audit
- **Hardware Integration**: Smart plug control stubbed with logging
- **Multi-tenancy**: Single venue for now, white-label expansion planned
- **Performance Testing**: Focus on correctness over scale at current stage