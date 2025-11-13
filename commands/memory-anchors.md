---
description: View anchor comment usage and cross-references across the project
---

# Memory Anchors

Shows anchor comment usage patterns, cross-references, and adoption metrics for your project.

## What This Command Does

Analyzes and displays:
1. **Total anchor comments** - Count of `<!-- ANCHOR -->` style comments
2. **Most referenced anchors** - Which anchors are used most often
3. **Orphaned anchors** - Anchors with no references (cleanup candidates)
4. **Cross-references** - Code files referencing documentation anchors
5. **Adoption metrics** - How well the team uses anchor comments

## Usage

```
/memory-anchors
```

Query specific anchor:
```
/memory-anchors AUTH-FLOW
```

## Example Output

```
📍 Anchor Comment Analysis

Total Anchors: 24
Most Referenced:
  • <!-- AUTH-FLOW --> (12 references across 5 files)
  • <!-- ERROR-HANDLING --> (8 references across 3 files)
  • <!-- DATABASE-SCHEMA --> (5 references across 2 files)

Orphaned Anchors (0 references):
  ⚠️ <!-- OLD-PAYMENT-FLOW --> - No references found. Consider removing.
  ⚠️ <!-- DEPRECATED-AUTH --> - Last referenced 3 months ago.

Recent Additions:
  ✓ <!-- API-VERSIONING --> added in src/api/README.md (2 days ago)
  ✓ <!-- RATE-LIMITING --> added in docs/CLAUDE.md (1 week ago)

Cross-References:
  src/api/auth.ts:45 → <!-- AUTH-FLOW -->
  src/api/errors.ts:12 → <!-- ERROR-HANDLING -->
  src/db/schema.ts:8 → <!-- DATABASE-SCHEMA -->

Adoption: 85% (24/28 suggested locations have anchors)
```

## Use Cases

### Check Anchor Consistency
```
/memory-anchors

Review which anchors are well-documented and cross-referenced.
```

### Find Documentation Gaps
```
Ask: "Which complex files need anchor comments?"

System identifies files without anchors that should have them.
```

### Clean Up Old Anchors
```
/memory-anchors

Lists orphaned anchors that can be safely removed.
```

## Automatic Tracking

The plugin automatically:
- ✓ Detects anchor comments in CLAUDE.md and markdown files
- ✓ Tracks references from code files
- ✓ Monitors anchor usage patterns
- ✓ Identifies documentation gaps

## Related Commands

- `/memory-context [anchor]` - Retrieve context about a specific anchor
- `/memory-overview` - Generate full project overview including anchors
- `/memory-status` - See tracking statistics
