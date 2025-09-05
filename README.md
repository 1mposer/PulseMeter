# PulseMeter

[![CI](https://github.com/1mposer/PulseMeter/actions/workflows/ci.yml/badge.svg)](https://github.com/1mposer/PulseMeter/actions/workflows/ci.yml)

![Coverage](https://img.shields.io/badge/coverage-local-lightgrey)


**PulseMeter** is a Rails 8.0–based Point-of-Sale system for billiard halls and similar venues.  
Features include **per-minute table pricing**, **membership tracking**, **comprehensive receipts**, **offline-first design**, and an **audit-ready architecture**.

---

## 🚀 Quick Start

### Prerequisites
- Ruby 3.3+
- Rails 8.0+
- SQLite (default) or PostgreSQL
- Git

### Installation
```bash
git clone <repo-url>
cd PulseMeter
bundle install
bin/rails db:setup  # Creates DB and runs all migrations
```

### Load Audit Demo Data
```bash
bin/rails runner db/seeds/audit_demo.rb  # Loads synthetic test data (no real customer info)
```

---

## 🧪 POS Workflow Demo

```bash
# 1. Open session via NFC/QR tag scan (uses table's default price: 0.50)
curl -X POST localhost:3000/scan/AUDIT_TAG_1/open \
  -H "Content-Type: application/json"

# OR with custom price override:
curl -X POST localhost:3000/scan/AUDIT_TAG_1/open \
  -H "Content-Type: application/json" \
  -d '{"price_per_minute": 0.75}'

# Note the session_id from response

# 2. Add drink purchase (use actual item ID from seeded data)
curl -X POST localhost:3000/sessions/{session_id}/drink_purchases \
  -H "Content-Type: application/json" \
  -d '{"item_id": 1, "quantity": 2}'

# 3. Add food purchase (use actual item ID from seeded data)
curl -X POST localhost:3000/sessions/{session_id}/food_purchases \
  -H "Content-Type: application/json" \
  -d '{"item_id": 11, "quantity": 1}'

# 4. Close session (generates complete receipt)
curl -X PATCH localhost:3000/sessions/{session_id} \
  -H "Content-Type: application/json" \
  -d '{"session": {"time_out": "2025-08-28T15:30:00Z"}}'
```

**Expected Result:**  
Complete JSON receipt with table time, drink/food purchases, and calculated totals.

---

## 🔒 Security & Quality Checks

### Static Analysis
```bash
bundle exec brakeman -A               # → 0 security warnings
bundle exec bundle audit check        # → No vulnerabilities found
bundle exec rubocop                   # → No offenses detected
RAILS_ENV=test bundle exec rails test # → All tests passing
```

### Database Integrity Verification
```bash
bin/rails runner "
puts ActiveRecord::Base.connection.index_exists?(
  :sessions, [:table_id, :time_out],
  name: 'index_sessions_on_table_single_open'
) ? '✅ Constraint verified' : '❌ Missing constraint'
"
```

---

## 🏗️ Architecture Overview

### Core Domain Models
- **Session:** Time-tracked table usage with per-minute pricing
- **Member:** Customer accounts with lifetime spending totals
- **Table:** Physical billiard tables with NFC/QR tag mapping
- **Tag:** NFC/QR identifiers for table access
- **Item:** Product catalog (drinks/food) with category validation
- **DrinkPurchase/FoodPurchase:** Purchase line items with price snapshots
- **CompletedSession:** Immutable archive of closed sessions

### Key Business Rules
- **Single Session Constraint:** One open session per table (DB enforced)
- **Money as Decimal:** All currency uses precise decimal arithmetic
- **Immutable Archive:** CompletedSession preserves full receipts
- **Category Validation:** Items strictly categorized as drink/food
- **Price Snapshots:** Purchases capture item price at sale time

### API Design Patterns
- **Serializers Own JSON:** All responses via dedicated serializer classes
- **RESTful Endpoints:** Standard HTTP methods and resource routing
- **Error Consistency:** Uniform error format via ErrorSerializer

---

## 📚 Documentation

- [`ARCHITECTURE.md`](./ARCHITECTURE.md) — Detailed system design and principles
- [`AUDIT_SCOPE.md`](./AUDIT_SCOPE.md) — External audit checklist and scope
- [`AUDIT_ACCESS.md`](./AUDIT_ACCESS.md) — Setup guide for security auditors

---

## 🗺️ Roadmap

- **Phase 1 (Complete):** Core billing system — sessions, members, purchases, receipts
- **Phase 2 (In Progress):** Offline-first sync with API idempotency (`X-Request-Id`)
- **Phase 3 (Planned):** Smart printer integration (LAN ESC/POS + Capacitor fallback)

---

## 🧪 Development

---

### Running Tests
```bash
RAILS_ENV=test bin/rails db:test:prepare
bundle exec rails test
```
With coverage enabled (SimpleCov):
```bash
RAILS_ENV=test bundle exec rails test
# → open coverage/index.html in your browser
```

### Code Quality
```bash
bin/rails server      # Start development server
bin/rails console     # Interactive Rails console
bin/rails routes      # View all API
```