> 
> 

---

## 1) Product Vision

- **Who:** Multi‑venue billiards operators in the UAE and beyond (e.g., Ricochet for casual play, Billiard Legends for pro/tournaments), plus their staff and players.
- **What:** A multi‑tenant billing + operations platform with optional self‑service QR check‑in, table control, POS for items, tournament management, and analytics with an AI advisor.
- **Why:** Replace slow/manual processes, reduce cashier friction, and provide data‑driven pricing and inventory decisions.
- **Success (MVP):** A venue can run the day fully: players check in, start/stop tables, pay; staff sell items; owner sees daily totals.

## 2) Personas & Jobs-to-be-done

- **Casual Venue (Ricochet):** Fast walk‑in start/stop, simple items, quick receipts, minimum staff interaction.
- **Pro Venue (Billiard Legends):** Tournament brackets, check‑in queues, lane/table assignment, payment links, live bracket screen.
- **Staff/Cashier:** override sessions, manual sells, handle edge cases.
- **Owner/Manager:** dashboards, pricing windows/happy hours, stock, export.
- **Player:** scan to check in, scan table to start/stop, optionally join/pay for tournaments.
- **Cashier/Staff:** start a table, sell drinks/snacks, charge & close tabs fast.
- **Owner:** inventory counts, daily revenue breakdown (sessions vs drinks), top items, member spend.
- **Member:** view history & savings (optional in phase 2).

## 3) Scope (MVP → Phase 2)

### Product bundles

- **Core Billing (baseline):** Sessions, Items/POS, Members, Dashboard.
- **Self‑Service QR (add‑on):** Venue entry QR → player session context; table QR → start/stop table + light control.
- **Tournaments (add‑on):** Sign‑up link/QR (WhatsApp‑shareable), payment (cash/Apple Pay link), bracket/match board on TV, results.
- **Analytics + AI Advisor (add‑on):** Aggregations + pricing recommendations (happy hours, item pricing, staffing hints).

### MVP (for first venue)

- Start/end a **Session**; auto compute cost; receipt; CompletedSession.
- **POS** for Items → DrinkPurchase callbacks (stock + member totals).
- **Dashboard**: today’s revenue, active tables, low stock.
- **QR PoC**: table QR to start/stop a session and toggle light.

### Phase 2

- Full **Self‑Service flow** (entry QR → register/guest, then table QR).
- **Tournaments**: entrants, payments, bracket, match results.
- Exports, user roles, audit log, price windows/happy‑hour rules.
- Charts and AI recommendations.

## 4) Core User Flows (acceptance criteria)

### 4.1 Entry QR (Self‑Service)

- Player scans venue QR → lightweight web page (no app) → choose **Start Playing**.
- System opens player session context (guest or links to Member).
- **AC:** player context created; appears in “Present” list.

### 4.2 Table QR Start/Stop

- Player scans table QR → **Start Table** (light on); time starts.
- Scan again or press **End Table** → time stops; receipt shown; optional pay link.
- **AC:** Session record with `table_id` updated; smart plug toggled; receipt generated.

### 4.3 Sell Item (POS)

- Staff taps item → creates **DrinkPurchase**; stock decremented; member spend incremented.
- **AC:** real‑time update via Turbo Stream on POS and Dashboard.

### 4.4 Dashboard View

- KPIs: Today revenue (sessions + drinks), active tables, low stock, top items.
- **AC:** server aggregates match DB; live updates without full reload.

### 4.5 Tournament Sign‑up & Board

- Venue shares link/QR (can forward via WhatsApp). Players join and pay (cash on arrival or Apple Pay link).
- Staff seeds/auto‑seeds bracket; TV shows real‑time matches & winners.
- **AC:** entrants list, payments logged, bracket updates.

## 5) Data Model (current)

### Organization / Venue (new for multi‑tenant)

- `organizations` (aka **venues**): name, branding, settings.
- `locations` (optional per venue): address/timezone.

### Table (new)

- `tables` (billiard tables): number/name, organization_id, device_id (smart plug), status.

### Session

- `time_in:datetime`, `time_out:datetime`, `price_per_minute:decimal`, `membership_id:integer`, `table_id:integer`
- **Methods:** `duration_mins`, `total_cost`, `print_receipt`

### CompletedSession

- `session_id:int`, `duration_mins:int`, `total_cost:decimal`, `membership_id:int`, `table_id:int`, `receipt:text`, `completed_at:datetime`, `price_per_minute:decimal`

### Member

- `name:string`, `email:string` (+ optional `phone`)
- `total_spent_sessions:decimal`, `total_spent_drinks:decimal`
- *(Phase 2)* `total_saved:decimal`, `discount_rate:decimal`

### Item

- `name:string`, `price:decimal`, `stock_quantity:int`, `category:string`, `organization_id`

### DrinkPurchase

- `member:references`, `item:references`, `amount:decimal`, `purchased_at:datetime`, `quantity:int`
- **Callback:** after_create → decrement item stock; increment member drink spend

### QR / Access (new)

- `qr_tokens`: scope (`entry` or `table`), `table_id` (nullable), `organization_id`, `expires_at`, `nonce`.

### Tournaments (Phase 2)

- `tournaments`: organization_id, name, entry_fee, bracket_type.
- `entrants`: tournament_id, member_id (or guest info), paid:boolean.
- `matches`: tournament_id, round, player_a_id, player_b_id, score_a, score_b, winner_id.

### Analytics & AI (Phase 2)

- Materialized rollups (daily revenue by source, item sales, peak hours) for fast charts.
- Simple feature store for AI advisor inputs (per‑hour occupancy, price bands, item margins).

## 6) Relationships

- Organization **has_many** Locations, Tables, Items, Members
- Member **has_many** Sessions, CompletedSessions, DrinkPurchases; **belongs_to** Organization
- Table **has_many** Sessions; **belongs_to** Organization
- Session **belongs_to** Member (optional) and **belongs_to** Table
- CompletedSession **belongs_to** Member and Table; optionally belongs_to Session
- Item **has_many** DrinkPurchases; **belongs_to** Organization
- DrinkPurchase **belongs_to** Item & Member

## 7) API/Routes (MVP)

- `POST /sessions` → start session
- `PATCH /sessions/:id` → end session + receipt (creates CompletedSession)
- `POST /drink_purchases` → create purchase
- `GET /dashboard` → aggregates for today (Turbo)
- `GET /items` → list for POS; `PATCH /items/:id` (stock adjustments)
- `GET /members/:id` → profile totals + recent activity
- **QR:** `GET /qr/entry` (renders entry page), `GET /qr/table/:id` (start/stop table), minimal auth via signed tokens
- **Tournaments (Phase 2):** `POST /tournaments`, `POST /tournaments/:id/entrants`, `POST /matches/:id/result`

## 8) UI Map (Hotwire + Tailwind)

- **Navbar:** Dashboard / POS / Sessions / Tables / Items / Members / Tournaments
- **Dashboard:** KPI cards (today revenue split), low stock, active tables
- **POS:** Item grid with Sell; Turbo Stream stock counters
- **Sessions:** Active & Completed lists; end-action updates in place
- **Tables:** list of tables with status/light indicator; QR code generator per table
- **Members:** index + detail (totals + recent)
- **Tournaments:** entrants list, bracket screen for TV
- **Entry/Scan pages:** minimal public views for QR flows

## 9) Non‑Functional Requirements

- **Multi‑tenant:** per‑organization data isolation; branding per venue.
- **Local-first:** SQLite okay; backup file nightly; optional Postgres later.
- **Simplicity:** PIN or lightweight auth for staff; public QR pages signed & time‑boxed.
- **Reliability:** Idempotent endpoints; device timeouts for light control.
- **Performance:** DB indexes on foreign keys; materialized daily rollups when needed.
- **Privacy:** No PII required for guests; opt‑in for members; GDPR‑style export/delete later.

## 10) Reporting/Analytics (Phase 2 detail)

- Revenue by day/week/month; sessions vs drinks split.
- Top items; low-stock alerts.
- Member spend & savings over time.

## 11) Open Questions / Decisions

- Do sessions always bind to a member? *(MVP: optional)*
- Exact discount model? per member vs per item vs happy-hour.
- Receipt delivery: print vs WhatsApp/Email? *(MVP: on-screen receipt)*
- Smart plug integration specifics (device/API?).

## 12) Milestones

- **M0 (Now):** Multi‑venue brief updated; schemas extended (Tables, QR, Tournaments outline).
- **M1:** QR Table Start/Stop PoC (toggle light + session time) + POS Sell flow live.
- **M2:** CompletedSession pipeline + Dashboard KPIs + low stock.
- **M3:** Entry QR flow (guest/member) + table QR end‑to‑end.
- **M4:** Tournament module (sign‑up link, entrants, bracket TV screen).
- **M5:** Analytics rollups + pricing windows; AI advisor v0 (simple rules → recommendations).

## 13) QA Checklist (MVP)

- 

---

### Notes & Next Steps

- Decide payment link flow (Apple Pay provider in UAE) & cash reconciliation.
- Confirm tournament bracket types (single elim/double) & seeding rules.
- Choose venue branding options (logo/colors) for white‑labeling.
- Name the product + bundles (e.g., **Core**, **Self‑Service**, **Tournaments**, **Analytics & AI**).

## 14) Delivery Plan & Phase Breakdown

> Timeboxes are rough; we can compress/expand. Each phase has a Definition of Done (DoD).
> 

### P0 — Foundation & Setup (0.5–1 day)

**Goals:** Rails 8 + Ruby 3.3.2 locked, Tailwind + Hotwire installed, repo tidy, seeds.
**DoD:** App boots; DB schema loads; seeds create demo members/items/tables; basic nav present.

### P1 — Core Billing Domain (1–2 days)

**Build:** Sessions start/end (JSON), `CompletedSession` creation, Items CRUD, `DrinkPurchase` with callbacks (stock↓, member total↑), Members totals.
**DoD:** Start/end session works via controller; creating a purchase updates stock and member totals; all visible in Rails console & minimal views.

### P2 — POS & Dashboard (1–2 days)

**Build:** POS item grid (Turbo Streams), low‑stock alert, Dashboard KPIs (today revenue split, active tables, top items).
**DoD:** Staff can sell from POS without refresh; dashboard numbers match DB sums.

### P3 — QR Table Start/Stop PoC (1–2 days)

**Build:** `tables` + `qr_tokens`; signed table QR; start/stop table toggles smart plug (mock); sessions track `table_id`.
**DoD:** Scanning table QR starts/stops a timed session and flips light in mock.

### P4 — Self‑Service Entry Flow (2–3 days)

**Build:** Entry QR → guest/member context; choose table → scan table QR; cashierless receipt.
**DoD:** A player can check in and complete a session with no staff.

### P5 — Tournaments MVP (2–3 days)

**Build:** `tournaments/entrants/matches`; WhatsApp‑shareable signup link; payments (cash + Apple Pay link provider); bracket TV screen.
**DoD:** Run a small bracket end‑to‑end with paid entrants and results.

### P6 — Analytics & AI v0 (2–3 days)

**Build:** Daily rollups; charts (Chartkick/Groupdate); price windows/happy hour; simple rule‑based advisor suggestions.
**DoD:** Owner dashboard shows trends + at least 3 actionable recommendations.

### P7 — Hardening & Multi‑tenant (ongoing)

**Build:** Org scoping everywhere, branding per venue, exports, backups, roles/PIN auth, device retry/timeout.
**DoD:** Two venues can run independently under one install; backup/restore tested.

---

## 15) Current Position

- ✅ Ruby 3.3.2 + Rails 8 in use.
- ✅ Models present: `Session` (with `duration_mins`, `total_cost`, `print_receipt`), `Member`, `Item`, `CompletedSession`.
- ✅ `DrinkPurchase` model generated and associations written; callback drafted (stock↓, member total↑).
- ⏳ `DrinkPurchase` migration: **pending/verify applied**.
- ⏳ `SessionsController` `update` helper refactor + `CompletedSession.create!` insertion.
- ⏳ Tailwind/Hotwire: not installed yet.
- ⏳ Dashboard/POS/QR/Tournaments: not started.


## Split Billing (Close-Open)
- Model: Session + SessionParticipant (join). Reallocate cost at event boundaries (join/leave/end).
- Receipt on leave = participant’s accrued share; remaining participant(s) keep accruing.
- Invariant: sum(participant costs) == session cost for processed window.
- Next: add `SessionParticipant` model + `sessions.last_split_at`, then implement `reallocate!(up_to:)`.
