# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Setup
```bash
bundle install
bin/rails db:setup  # Creates DB and runs all migrations
bin/rails runner db/seeds/audit_demo.rb  # Load synthetic test data
```

### Testing & Quality
```bash
# Run tests
RAILS_ENV=test bin/rails db:test:prepare
bundle exec rails test

# With coverage (SimpleCov enabled)
RAILS_ENV=test bundle exec rails test
# View coverage at coverage/index.html

# Security & static analysis
bundle exec brakeman -A               # Security scan
bundle exec bundle audit check        # Vulnerability check
bundle exec rubocop                   # Code style
```

### Development Server
```bash
bin/rails server      # Start development server
bin/rails console     # Interactive Rails console
bin/rails routes      # View all API routes
```

## Architecture Overview

PulseMeter is a Rails 8 point-of-sale system for pool halls with an API-first, JSON-only design.

### Core Domain Models
- **Session**: Time-tracked table usage with per-minute pricing (duration rounded up to next minute)
- **Member**: Optional customer accounts with lifetime spending totals
- **Table**: Physical billiard tables with NFC/QR tag mapping
- **Tag**: NFC/QR identifiers for table access
- **Item**: Product catalog (drinks/food) with strict category validation
- **DrinkPurchase/FoodPurchase**: Purchase line items with price snapshots
- **CompletedSession**: Immutable archive of closed sessions with full receipt JSON

### Key Business Rules
- **Single Session Constraint**: Only one open session per table (DB-enforced with unique partial index)
- **Money as Decimal**: All currency uses `decimal` type with precision: 10, scale: 2
- **Immutable Archive**: CompletedSession preserves complete receipts when sessions close
- **Price Snapshots**: Purchases capture item price at time of sale
- **State Integrity**: Sessions can only be open → closed or open → voided

### API Design Patterns
- **JSON-only responses**: All routes have `defaults: { format: :json }`
- **Serializers Own JSON**: All responses use dedicated serializer classes (never ad-hoc JSON)
- **RESTful routing**: Standard HTTP methods for session management
- **Error consistency**: Uniform error format via ErrorSerializer

### Critical Endpoints
```bash
# Open session via NFC/QR scan
POST /scan/{tag_token}/open

# Manage session
PATCH /sessions/{id}  # Close session (set time_out)
POST /sessions/{id}/void  # Void session
POST /sessions/{id}/drink_purchases  # Add drink purchase
POST /sessions/{id}/food_purchases   # Add food purchase
```

### Database Constraints
- Unique partial index enforces single open session per table:
  `index_sessions_on_table_single_open ON sessions (table_id, time_out) WHERE (time_out IS NULL AND voided_at IS NULL)`
- All monetary calculations use precise decimal arithmetic
- Foreign key constraints ensure referential integrity

### Development Notes
- Uses Hotwire (Turbo + Stimulus) for frontend
- SQLite default, PostgreSQL supported
- SimpleCov coverage tracking enabled in test environment
- Security tools: Brakeman, bundle audit, Rubocop Rails Omakase style
- No authentication implemented yet (API-first design)

---

## Session Logs

**IMPORTANT**: This section contains session-specific context and instructions. Only access when explicitly granted permission by the user.

### 2024-09-14: Rails Codebase Audit (Pass 1-3)

**Current Step**: Rails Codebase Audit (Pass 1–3)

**Purpose**: Before introducing Spec-Kit, running a three-pass audit loop on the Rails codebase.
Goal: **inventory → linkage → consistency**.

**Where We Are**: Pass 1 (Inventory) — in progress

**Pass 1 — Inventory (What exists)**
- [ ] Install dev gems (`rails-erd`, `railroady`, `annotate`, `rubocop`, `reek`, `brakeman`)
- [ ] Install Graphviz (`brew install graphviz` / `apt-get install graphviz`)
- [ ] Create `tmp/audit/` folder & ignore it in git
- [ ] Generate routes (`bin/rails routes --expanded`)
- [ ] Copy schema snapshot (`db/schema.rb` or `structure.sql`)
- [ ] List models & controllers (`find app/models …`)
- [ ] Render ERD (`bundle exec erd`)
- [ ] Render graphs (`railroady -M` / `C`)
- [ ] Run static analysis (`rubocop`, `reek`, `brakeman`)
- [ ] Annotate models with schema info

**Pass 2 — Linkage (What points to what)**
- [ ] Build Association Ledger (who belongs to who)
- [ ] Build Callback Ledger (events → methods → side effects)
- [ ] Build Denormalized Fields Ledger (e.g., total_spent_drinks, total_spent_food)
- [ ] Build Controller→Model Flow Map (params → methods → DB writes)
- [ ] Flag orphaned methods, routes, denorm fields with no owners

**Pass 3 — Consistency (Code ↔ DB rules)**
- [ ] Cross-check validations vs DB constraints
- [ ] Ensure `uniqueness` validations have unique DB indexes
- [ ] Ensure `presence` validations have `NOT NULL` in DB
- [ ] Confirm foreign keys align with `dependent:` behavior
- [ ] Confirm denorm totals update on **create/update/destroy**
- [ ] Write migration tasks for gaps

**Definition of Done**:
- [ ] `tmp/audit/` contains full inventories + reports
- [ ] ERD + model/controller graphs render cleanly
- [ ] Ledgers exist for associations, callbacks, denorm fields
- [ ] Consistency report written (migrations listed)
- [ ] README includes "How to Re-Run Audit Loop" section