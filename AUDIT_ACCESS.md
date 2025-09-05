# Audit Access Setup Guide

## 🚀 Quick Start (No Secrets Required)

### Prerequisites
- Ruby 3.x+ 
- Rails 8.x+
- SQLite (default) or PostgreSQL
- Git

### Local Setup
```bash
git clone <repo-url>
cd ricochet-billing

# Install dependencies
bundle install

# Setup database (applies new migrations)
bin/rails db:setup

# Verify migration success - should see single session constraint
bin/rails db:schema:dump
grep -A 5 "index_sessions_on_table_single_open" db/schema.rb

# Load audit demo data
bin/rails runner db/seeds/audit_demo.rb

# Start server  
bin/rails server
```

### Audit Demo Workflow
Test the complete purchase flow:

```bash
# 1. Open session via tag scan
curl -X POST localhost:3000/scan/AUDIT_TAG_1/open \
  -H "Content-Type: application/json" \
  -d '{"price_per_minute": 0.50}'

# Note the session_id from response

# 2. Add drink purchase
curl -X POST localhost:3000/sessions/{session_id}/drink_purchases \
  -H "Content-Type: application/json" \
  -d '{"item_id": 1, "quantity": 2}'

# 3. Add food purchase  
curl -X POST localhost:3000/sessions/{session_id}/food_purchases \
  -H "Content-Type: application/json" \
  -d '{"item_id": 2, "quantity": 1}'

# 4. Close session (generates receipt)
curl -X PATCH localhost:3000/sessions/{session_id} \
  -H "Content-Type: application/json" \
  -d '{"session": {"time_out": "2025-08-28T15:30:00Z"}}'

# 5. Verify immutable archive created
bin/rails console
> CompletedSession.last.receipt  # Should contain full receipt JSON
```

## 🔍 CI & Security Checks

### Run All Static Checks Locally
```bash
# Security scan
bundle exec brakeman -A

# Dependency vulnerabilities  
bundle exec bundle audit check --update

# Code style & quality
bundle exec rubocop -A

# Test suite
RAILS_ENV=test bin/rails db:test:prepare
bundle exec rspec
```

### Expected "Good" Outputs
- **brakeman**: "0 security warnings"
- **bundle audit**: "No known vulnerabilities found" 
- **rubocop**: "No offenses detected"
- **rspec**: All tests green, coverage >90%

### If Ruby Environment Issues
If Ruby/Rails not available locally:
1. Use Docker: `docker run -v $(pwd):/app -w /app ruby:3.2 bash`
2. Or request VM access with pre-configured environment
3. Core code review can proceed without execution

## 📋 Human-Only Setup Steps

**⚠️ Repository Owner Must Complete These Before Audit:**

### Repository Security
- [ ] Ensure repo is **private** (no public mirrors)
- [ ] **Disable forking** in repository settings
- [ ] **Branch protections** on main branch:
  - [ ] Require PR reviews (minimum 1)
  - [ ] Disallow force pushes
  - [ ] Require CI status checks to pass
- [ ] **2FA required** for all organization members
- [ ] **Collaborator access**: Add auditor as **Read-only** collaborator with **expiration date**

### Legal & Access Controls
- [ ] **Signed NDA** and audit contract in place
- [ ] **Escrow agreement** for findings/deliverables  
- [ ] **Temporary access only** - remove auditor access immediately after completion
- [ ] **Rotate credentials** - any shared sandbox/dev keys rotated post-audit

### Audit Management
- [ ] **GitHub Project board** created: "Security Audit Findings" with columns (New/In Review/Resolved)
- [ ] **Issue labels** configured: `audit-critical`, `audit-major`, `audit-minor`, `audit-resolved`
- [ ] **Audit timeline** communicated (target completion date)

## 🔧 Development Environment

### Database Migrations Status
**⚠️ Important**: New migrations need to be applied. Current schema is outdated.

Required migrations to run:
```bash
# These migrations add Phase 2 features:
# - Fix DrinkPurchase table structure  
# - Create FoodPurchase table
# - Add session fields (table_id, tag_id, voided_at, etc.)
# - Add single session per table constraint

bin/rails db:migrate
```

### Environment Variables
Copy `.env.example` to `.env` if using environment-based configuration. No secrets required for audit demo.

### Troubleshooting
- **Migration errors**: Ensure clean DB with `bin/rails db:drop db:create db:migrate`  
- **Seed failures**: Check that migrations ran successfully first
- **Test failures**: Verify test DB is prepared with `RAILS_ENV=test bin/rails db:migrate`

## 📊 Reporting Findings

### Issue Template Location
Use `.github/ISSUE_TEMPLATE/audit.md` template for all findings.

### Severity Guidelines
- **Critical**: Security vulnerabilities, data corruption risks
- **Major**: Business logic errors, performance issues, architectural concerns  
- **Minor**: Code style, documentation gaps, minor bugs

### Required Information
- File path and line number references
- Steps to reproduce
- Expected vs actual behavior  
- Proposed fix (if applicable)
- Business impact assessment

## 📞 Contact & Escalation

For urgent security findings or access issues, contact repository owner immediately. All other findings should be filed as GitHub issues with appropriate severity labels.