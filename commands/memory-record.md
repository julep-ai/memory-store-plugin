---
description: Record important information to memory store manually
---

# Memory Record

Manually records important information, decisions, or context to the memory store. Use this when you want to ensure something is explicitly remembered.

## What this command does

1. **Stores explicit memory**: Records your input with high priority
2. **Captures context**: Includes current project and session context
3. **Enables future recall**: Makes information available for `/memory-recall`
4. **Persists across sessions**: Memory available to you and your team
5. **Enriches project knowledge**: Builds shared team understanding

## Usage

```
/memory-record "important information to remember"
```

## Examples

### Record a Decision
```
/memory-record "We decided to use PostgreSQL over MongoDB for ACID compliance. Rejected MongoDB due to consistency concerns for financial transactions. Decision made Nov 13, 2025. Stakeholders: Security Team, Engineering."
```

### Record a Pattern
```
/memory-record "All API endpoints must use OAuth2 password flow for authentication. See src/api/auth.ts:45 for implementation pattern. This is a security requirement."
```

### Record Business Context
```
/memory-record "Payment processing flow must complete within 30 seconds per compliance requirements. Any longer triggers automatic rollback. Critical for SLA."
```

### Record Team Convention
```
/memory-record "Frontend components use React hooks exclusively. Class components are deprecated. New code must follow hooks pattern."
```

## When to Use

- ✅ After important architectural decisions
- ✅ When establishing new conventions
- ✅ To document business requirements
- ✅ Recording critical constraints
- ✅ Sharing team knowledge explicitly

## Automatic vs Manual

**Automatic Recording** (happens in background):
- File changes
- Git commits
- Errors and corrections
- Patterns detected

**Manual Recording** (this command):
- Explicit decisions
- Important context
- Business rules
- Team conventions

## Related Commands

- `/memory-recall [query]` - Retrieve stored memories
- `/memory-overview` - Generate project overview
- `/memory-status` - View tracking status
- `/correct "info"` - Record high-priority correction

## Note

Most recording happens **automatically** in the background. Use `/memory-record` for explicit, important information you want to ensure is captured.
