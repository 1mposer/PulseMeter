PulseMeter Duplication Elimination Plan                                                                          │ │
│ │                                                                                                                  │ │
│ │ Overview                                                                                                         │ │
│ │                                                                                                                  │ │
│ │ Systematic 3-phase refactoring to eliminate ~300 lines of duplicate code while maintaining API compatibility.    │ │
│ │                                                                                                                  │ │
│ │ Phase 1: Core Model Cleanup (High Priority)                                                                      │ │
│ │                                                                                                                  │ │
│ │ Goal: Consolidate purchase model logic into shared concern                                                       │ │
│ │                                                                                                                  │ │
│ │ Tasks:                                                                                                           │ │
│ │                                                                                                                  │ │
│ │ 1. Create PurchaseBehavior concern (app/models/concerns/purchase_behavior.rb)                                    │ │
│ │   - Shared validations (quantity, unit_price_at_sale, total_price)                                               │ │
│ │   - Shared methods (calculate_total_price, session_must_be_open, sufficient_stock_available)                     │ │
│ │   - Parameterized member total updates (total_spent_drinks vs total_spent_food)                                  │ │
│ │   - Shared callbacks (before_save, after_create, after_destroy)                                                  │ │
│ │ 2. Refactor DrinkPurchase model                                                                                  │ │
│ │   - Include PurchaseBehavior concern                                                                             │ │
│ │   - Remove duplicated methods and validations                                                                    │ │
│ │   - Keep drink-specific logic only                                                                               │ │
│ │ 3. Refactor FoodPurchase model                                                                                   │ │
│ │   - Include PurchaseBehavior concern                                                                             │ │
│ │   - Remove duplicated methods and validations                                                                    │ │
│ │   - Keep food-specific logic only                                                                                │ │
│ │ 4. Test Phase 1 thoroughly                                                                                       │ │
│ │   - Verify purchase calculations still work                                                                      │ │
│ │   - Verify member totals update correctly                                                                        │ │
│ │   - Verify stock validation functions                                                                            │ │
│ │   - Run full test suite                                                                                          │ │
│ │                                                                                                                  │ │
│ │ Estimated Impact: Reduce models from ~120 lines each to ~30 lines each                                           │ │
│ │                                                                                                                  │ │
│ │ Phase 2: Controller Streamlining (Medium Priority)                                                               │ │
│ │                                                                                                                  │ │
│ │ Goal: Eliminate controller method duplication                                                                    │ │
│ │                                                                                                                  │ │
│ │ Tasks:                                                                                                           │ │
│ │                                                                                                                  │ │
│ │ 1. Add before_action callback                                                                                    │ │
│ │   - before_action :find_session, except: [:create]                                                               │ │
│ │   - Remove 6 instances of @session = Session.find(params[:id])                                                   │ │
│ │ 2. Create unified purchase method                                                                                │ │
│ │   - Single create_purchase(purchase_type) private method                                                         │ │
│ │   - Handle both 'drink' and 'food' types with parameter                                                          │ │
│ │   - Maintain identical API responses and error handling                                                          │ │
│ │ 3. Replace duplicate purchase actions                                                                            │ │
│ │   - Update create_drink_purchase to call create_purchase('drink')                                                │ │
│ │   - Update create_food_purchase to call create_purchase('food')                                                  │ │
│ │   - Preserve existing route structure (no API changes)                                                           │ │
│ │ 4. Add error handling helper                                                                                     │ │
│ │   - render_error(message, status) method                                                                         │ │
│ │   - Replace 8+ instances of error rendering boilerplate                                                          │ │
│ │ 5. Test Phase 2 thoroughly                                                                                       │ │
│ │   - Verify API responses remain identical                                                                        │ │
│ │   - Test error scenarios and status codes                                                                        │ │
│ │   - Verify purchase creation still works for both types                                                          │ │
│ │                                                                                                                  │ │
│ │ Estimated Impact: Reduce controller from ~136 lines to ~80 lines                                                 │ │
│ │                                                                                                                  │ │
│ │ Phase 3: Serializer Consolidation (Lower Priority)                                                               │ │
│ │                                                                                                                  │ │
│ │ Goal: Extract shared serialization logic                                                                         │ │
│ │                                                                                                                  │ │
│ │ Tasks:                                                                                                           │ │
│ │                                                                                                                  │ │
│ │ 1. Create ApplicationSerializer base class                                                                       │ │
│ │   - Shared format_money(amount) method                                                                           │ │
│ │   - Common helper methods                                                                                        │ │
│ │ 2. Create serialization modules                                                                                  │ │
│ │   - MemberInfoSerializer module for member_info method                                                           │ │
│ │   - TableInfoSerializer module for table_info method                                                             │ │
│ │                                                                                                                  │ │
│ │ 3. Update existing serializers                                                                                   │ │
│ │   - SessionSerializer, PurchaseSerializer, ReceiptSerializer inherit from ApplicationSerializer                  │ │
│ │   - Include appropriate modules                                                                                  │ │
│ │   - Remove duplicate methods                                                                                     │ │
│ │ 4. Test Phase 3 thoroughly                                                                                       │ │
│ │   - Verify JSON responses remain byte-identical                                                                  │ │
│ │   - Test all API endpoints for response consistency                                                              │ │
│ │   - Run integration tests                                                                                        │ │
│ │                                                                                                                  │ │
│ │ Estimated Impact: Reduce serializer duplication by ~30 lines                                                     │ │
│ │                                                                                                                  │ │
│ │ Testing Strategy                                                                                                 │ │
│ │                                                                                                                  │ │
│ │ - After each phase: Run full test suite                                                                          │ │
│ │ - API compatibility: No breaking changes to existing endpoints                                                   │ │
│ │ - Integration testing: Verify client compatibility maintained                                                    │ │
│ │ - Business logic: Special focus on purchase calculations and member totals                                       │ │
│ │                                                                                                                  │ │
│ │ Risk Management                                                                                                  │ │
│ │                                                                                                                  │ │
│ │ - Rollback plan: Each phase is independent and reversible                                                        │ │
│ │ - Progressive deployment: Test each phase thoroughly before proceeding                                           │ │
│ │ - API contract: Maintain exact response formats and error messages                                               │ │
│ │                                                                                                                  │ │
│ │ Success Metrics                                                                                                  │ │
│ │                                                                                                                  │ │
│ │ - ✅ ~300 lines of duplicate code eliminated                                                                      │ │
│ │ - ✅ Single source of truth for purchase logic                                                                    │ │
│ │ - ✅ Improved maintainability and consistency                                                                     │ │
│ │ - ✅ Zero API breaking changes                                                                                    │ │
│ │ - ✅ All tests passing after each phase

