---
name: Security Audit Finding
about: Report security, code quality, or architectural issues found during external audit
title: '[AUDIT] '
labels: ['audit-finding', 'needs-triage']
assignees: []

---

## 🔍 Finding Summary
Brief description of the issue discovered.

## 📍 Location
**File(s) affected:**
- `path/to/file.rb:123`
- `path/to/another/file.rb:45-67`

**Component/Module:** (e.g., Sessions, Purchases, Serializers, etc.)

## 🚨 Severity Level
- [ ] **Critical** - Security vulnerability, data corruption risk, system compromise
- [ ] **Major** - Business logic error, performance issue, architectural concern  
- [ ] **Minor** - Code style, documentation gap, non-breaking improvement

## 📋 Steps to Reproduce
1. Set up local environment with `bin/setup`
2. Run audit demo: `bin/rails runner db/seeds/audit_demo.rb`
3. Execute: `[specific command or API call]`
4. Observe: `[describe the problem]`

## ✅ Expected Behavior
What should happen according to business requirements or security best practices.

## ❌ Actual Behavior  
What actually happens, including error messages, unexpected outputs, or security concerns.

## 🧪 Test Case
```ruby
# Add a test case that reproduces the issue
describe "SessionsController" do
  it "should prevent unauthorized access" do
    # test code here
  end
end
```

## 💡 Proposed Fix
**Option 1:** [Recommended approach]
- Code changes needed
- Migration requirements  
- Testing considerations

**Option 2:** [Alternative approach if applicable]
- Trade-offs and considerations

## 📊 Business Impact
- [ ] **Security Risk** - Could lead to data breach or unauthorized access
- [ ] **Data Integrity** - Could cause incorrect calculations or data corruption
- [ ] **Performance** - Could impact system performance or scalability
- [ ] **User Experience** - Could affect end-user functionality
- [ ] **Compliance** - Could affect regulatory compliance
- [ ] **Technical Debt** - Code maintainability concern

## 🔗 Related Issues
- Links to related GitHub issues
- References to external resources or documentation
- Related audit findings

## 📝 Additional Context
Any additional context, screenshots, logs, or background information.

---

**Auditor:** [Your name/organization]  
**Date Found:** [YYYY-MM-DD]  
**Audit Phase:** [Phase 2 Verification / Security Review / etc.]