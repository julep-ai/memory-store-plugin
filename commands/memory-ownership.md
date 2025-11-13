---
description: View code ownership patterns and expertise distribution across the team
---

# Memory Ownership

Displays code ownership patterns, expertise areas, and contribution metrics based on git commit analysis.

## What This Command Does

Analyzes and shows:
1. **Code ownership** - Who owns which parts of the codebase
2. **Expertise areas** - Team members' areas of specialization
3. **Contribution patterns** - When and how team members contribute
4. **Knowledge gaps** - Areas with no clear owner
5. **Collaboration patterns** - How team members work together

## Usage

```
/memory-ownership
```

Check specific person:
```
/memory-ownership alice@company.com
```

Check specific area:
```
/memory-ownership frontend
```

## Example Output

```
👥 Code Ownership Map

Overall Distribution:
  • Alice Chen: 45% commits (backend-api specialist)
  • Bob Smith: 35% commits (frontend specialist)
  • Charlie Lee: 20% commits (testing & tooling)

Area Ownership:

Backend API (src/api/):
  🏆 Alice Chen - 80% commits
     Last active: 2 days ago
     Expertise: authentication, database, error handling

  Supporting: Bob Smith - 15%, Charlie Lee - 5%

Frontend (src/components/):
  🏆 Bob Smith - 90% commits
     Last active: 1 day ago
     Expertise: React components, state management, UI

  Supporting: Alice Chen - 10%

Testing (tests/):
  🏆 Charlie Lee - 70% commits
     Last active: 3 days ago
     Expertise: integration tests, E2E, test infrastructure

  Supporting: Alice Chen - 20%, Bob Smith - 10%

Knowledge Gaps (⚠️ no clear owner):
  • deployment/ - Last touched 3 months ago by ex-team member
  • scripts/migration/ - No recent commits
  • docs/architecture/ - Outdated, needs review

Commit Patterns:
  Alice: Commits mostly 2-5pm, prefers feat: and fix: types
  Bob: Morning contributor (9am-12pm), uses refactor: often
  Charlie: Afternoon focus (1-6pm), test: and chore: heavy

Recent Activity:
  ✓ Alice added feature in backend-api (2 days ago)
  ✓ Bob refactored frontend components (1 day ago)
  ⚠️ No commits to deployment/ in 90 days
```

## Use Cases

### Find the Expert
```
/memory-ownership authentication

Shows: "Alice Chen owns authentication (80% commits, last active 2 days ago)"
```

### Identify Knowledge Silos
```
/memory-ownership

Reveals areas with single owner (bus factor risk)
```

### Plan Code Reviews
```
Ask: "Who should review my frontend changes?"

System suggests: "Bob Smith (90% frontend commits) is the expert"
```

### Onboard New Members
```
/memory-ownership

New developer sees clear ownership map and who to ask
```

## Automatic Tracking

The plugin automatically:
- ✓ Tracks every commit author and files changed
- ✓ Analyzes commit types (feat, fix, docs, etc.)
- ✓ Identifies expertise areas by activity patterns
- ✓ Detects knowledge gaps and stale code
- ✓ Records collaboration patterns

## Business Context

Ownership data helps with:
- **Risk Management** - Identify single points of failure
- **Team Planning** - Balance workload and expertise
- **Hiring Decisions** - See where expertise gaps exist
- **Code Reviews** - Route to appropriate experts
- **Onboarding** - New members know who owns what

## Related Commands

- `/memory-context [person]` - Retrieve all work by a specific person
- `/memory-overview` - Full project overview including ownership
- `/correct "[person] owns [area]"` - Manually set ownership information
