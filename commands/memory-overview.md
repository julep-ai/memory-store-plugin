---
description: Generate comprehensive project overview from memory store
---

# Memory Overview

Generates a comprehensive overview of the project by analyzing the memory store, git history, CLAUDE.md files, and development patterns. Provides a holistic view of project architecture, business logic, and team conventions.

## What this command generates

1. **Project architecture**: High-level structure and key components
2. **Business logic overview**: Core business rules and workflows
3. **Development patterns**: Established coding conventions and patterns
4. **Technology stack**: Languages, frameworks, and tools used
5. **Team conventions**: Coding standards, commit patterns, branching strategy
6. **Key decisions**: Important architectural and technical decisions
7. **Active areas**: Currently active development areas
8. **Knowledge gaps**: Areas with less documentation or context

## Usage

```
/memory-overview
```

## Options

```
/memory-overview --format=markdown
/memory-overview --format=json
/memory-overview --save-to=PROJECT_OVERVIEW.md
/memory-overview --detailed
```

## Example Output

```
User: /memory-overview

Claude: Project Overview - E-Commerce Platform
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Generated from 247 memories, 150+ commits, 5 CLAUDE.md files

## Architecture Overview

### Frontend (React + TypeScript)
- Component structure: Atomic design pattern
- State management: Redux Toolkit
- Routing: React Router v6
- Styling: Tailwind CSS + CSS Modules

Key directories:
- src/components/ - Reusable UI components
- src/pages/ - Page-level components
- src/store/ - Redux state management
- src/api/ - API client layer

### Backend (Node.js + Express)
- Architecture: RESTful API with service layer pattern
- Database: PostgreSQL with Prisma ORM
- Authentication: OAuth2 + JWT tokens
- File structure: Feature-based modules

Key directories:
- src/api/ - API routes and controllers
- src/services/ - Business logic layer
- src/models/ - Database models
- src/middleware/ - Express middleware

## Business Logic

### Core Workflows
1. **User Authentication** (src/api/auth.ts)
   - OAuth2 flow with Google/GitHub
   - JWT token-based sessions
   - Automatic token refresh
   - Documented: CLAUDE.md <!-- AUTH-FLOW -->

2. **Product Catalog** (src/services/products.ts)
   - Dynamic pricing rules
   - Inventory management
   - Category hierarchy
   - Search with Elasticsearch

3. **Order Processing** (src/services/orders.ts)
   - Multi-step checkout flow
   - Payment integration (Stripe)
   - Order fulfillment pipeline
   - Email notifications

## Development Patterns

### Coding Conventions
- TypeScript strict mode enabled
- ESLint + Prettier for code formatting
- Functional components with hooks
- Error handling: Standardized error codes
- Testing: Jest + React Testing Library

### Commit Patterns
- Conventional commits (feat:, fix:, docs:, etc.)
- Branch naming: feature/, bugfix/, hotfix/
- PR requirements: Tests + review
- Squash merges to main

### Key Decisions

1. **Why PostgreSQL over MongoDB?** (3 months ago)
   - Decision: Use PostgreSQL for ACID compliance
   - Reasoning: Complex relationships, transactions needed
   - Team consensus in session mem-2024-10-15-xyz

2. **OAuth2 Authentication** (2 months ago)
   - Decision: Implement OAuth2 instead of basic auth
   - Reasoning: Better security, SSO support, industry standard
   - Implementation: src/api/auth.ts

3. **Service Layer Pattern** (1 month ago)
   - Decision: Separate business logic from API routes
   - Reasoning: Better testability, code organization
   - Pattern: src/services/*

## Active Development Areas

Current sprint focus:
- 🔥 Payment integration (Stripe)
- 🔥 Admin dashboard redesign
- 📝 API documentation (OpenAPI)
- 🧪 E2E test coverage improvement

Recent commits (last 7 days):
- 15 commits on payment features
- 8 commits on admin UI
- 5 commits on testing

## Team Conventions

### CLAUDE.md Anchor Comments
- <!-- AUTH-FLOW --> - Authentication patterns
- <!-- API-SECURITY --> - API security guidelines
- <!-- DB-SCHEMA --> - Database schema decisions
- <!-- ERROR-HANDLING --> - Error handling conventions
- <!-- TESTING-GUIDE --> - Testing best practices

### Code Review Guidelines
- Minimum 1 approval required
- Tests must pass
- No console.logs in production code
- Update CLAUDE.md for new patterns

## Knowledge Gaps

Areas needing more documentation:
⚠️ Payment webhook handling
⚠️ Database backup strategy
⚠️ Deployment pipeline
⚠️ Performance monitoring setup

## Statistics

- Total files: 450+
- Lines of code: ~85,000
- Test coverage: 78%
- Team size: 5 developers
- Project age: 6 months
- Last major refactor: 2 weeks ago

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This overview is continuously updated as development progresses.
Last updated: 5 minutes ago
Next sync: Automatic on session end
```

## Use Cases

### For New Team Members
```
/memory-overview --save-to=ONBOARDING.md
```
Creates a comprehensive onboarding document.

### For Documentation
```
/memory-overview --format=markdown > PROJECT_OVERVIEW.md
```
Generates markdown documentation.

### For Stakeholder Updates
```
/memory-overview --format=json | jq '.active_areas'
```
Extracts specific sections for reports.

## Related Commands

- `/memory-sync` - Sync current state to memory
- `/memory-status` - View tracking status
- `/memory-context` - Retrieve specific context
