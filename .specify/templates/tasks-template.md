# Tasks: [FEATURE NAME]

**Input**: Design documents from `/specs/[###-feature-name]/`
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/

## Execution Flow (main)

```
1. Load plan.md from feature directory
   → If not found: ERROR "No implementation plan found"
   → Extract: tech stack, libraries, structure
2. Load optional design documents:
   → data-model.md: Extract entities → model tasks
   → contracts/: Each file → contract test task
   → research.md: Extract decisions → setup tasks
3. Generate tasks by category:
   → Setup: project init, dependencies, linting
   → Tests: contract tests, integration tests
   → Core: models, services, CLI commands
   → Integration: DB, middleware, logging
   → Polish: unit tests, performance, docs
4. Apply task rules:
   → Different files = mark [P] for parallel
   → Same file = sequential (no [P])
   → Tests before implementation (TDD)
5. Number tasks sequentially (T001, T002...)
6. Generate dependency graph
7. Create parallel execution examples
8. Validate task completeness:
   → All contracts have tests?
   → All entities have models?
   → All endpoints implemented?
9. Return: SUCCESS (tasks ready for execution)
```

## Format: `[ID] [P?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

## Path Conventions

- **Single project**: `src/`, `tests/` at repository root
- **Web app**: `backend/src/`, `frontend/src/`
- **Mobile**: `api/src/`, `ios/src/` or `android/src/`
- Paths shown below assume single project - adjust based on plan.md structure

## Phase 3.1: Setup

**CONSTITUTIONAL REQUIREMENT: Code Quality Standards (Principle I)**

- [ ] T001 Create project structure per implementation plan
- [ ] T002 Initialize [language] project with [framework] dependencies
- [ ] T003 [P] Configure linting and formatting tools (static analysis gates)
- [ ] T004 [P] Configure security scanning tools
- [ ] T005 [P] Set up code coverage reporting (80% minimum target)
- [ ] T006 [P] Configure performance monitoring and structured logging

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3

**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**
**CONSTITUTIONAL REQUIREMENT: Test-First Development (Principle II)**

- [ ] T004 [P] Contract test POST /api/users in tests/contract/test_users_post.py
- [ ] T005 [P] Contract test GET /api/users/{id} in tests/contract/test_users_get.py
- [ ] T006 [P] Integration test user registration in tests/integration/test_registration.py
- [ ] T007 [P] Integration test auth flow in tests/integration/test_auth.py
- [ ] T008 [P] Performance test API response times (<200ms) in tests/performance/test_response_times.py
- [ ] T009 [P] Accessibility test user workflows (WCAG 2.1 AA) in tests/accessibility/test_a11y.py

## Phase 3.3: Core Implementation (ONLY after tests are failing)

**CONSTITUTIONAL REQUIREMENT: Code Quality Standards + UX Consistency (Principles I & III)**

- [ ] T010 [P] User model in src/models/user.py
- [ ] T011 [P] UserService CRUD in src/services/user_service.py
- [ ] T012 [P] CLI --create-user in src/cli/user_commands.py
- [ ] T013 POST /api/users endpoint
- [ ] T014 GET /api/users/{id} endpoint
- [ ] T015 Input validation with consistent error messages
- [ ] T016 Error handling with structured logging and user-friendly responses
- [ ] T017 [P] UI components following design system patterns
- [ ] T018 [P] Accessibility implementation (ARIA labels, keyboard navigation)

## Phase 3.4: Integration

**CONSTITUTIONAL REQUIREMENT: Performance + Observability (Principles IV & V)**

- [ ] T019 Connect UserService to DB with query optimization
- [ ] T020 Auth middleware with performance monitoring
- [ ] T021 Request/response logging with structured format
- [ ] T022 CORS and security headers
- [ ] T023 Database connection pooling and monitoring
- [ ] T024 API response time monitoring and alerting

## Phase 3.5: Polish

**CONSTITUTIONAL REQUIREMENT: Quality Gates Validation**

- [ ] T025 [P] Unit tests for validation in tests/unit/test_validation.py
- [ ] T026 Performance regression tests (<200ms API, <2s frontend load)
- [ ] T027 [P] Update docs/api.md with accessibility guidelines
- [ ] T028 Code quality review and duplication removal
- [ ] T029 Static analysis gates validation
- [ ] T030 User experience consistency audit
- [ ] T031 Security scanning and vulnerability assessment
- [ ] T032 Code coverage verification (80% minimum)
- [ ] T033 Run manual accessibility testing

## Dependencies

- Tests (T004-T007) before implementation (T008-T014)
- T008 blocks T009, T015
- T016 blocks T018
- Implementation before polish (T019-T023)

## Parallel Example

```
# Launch T004-T007 together:
Task: "Contract test POST /api/users in tests/contract/test_users_post.py"
Task: "Contract test GET /api/users/{id} in tests/contract/test_users_get.py"
Task: "Integration test registration in tests/integration/test_registration.py"
Task: "Integration test auth in tests/integration/test_auth.py"
```

## Notes

- [P] tasks = different files, no dependencies
- Verify tests fail before implementing
- Commit after each task
- Avoid: vague tasks, same file conflicts

## Task Generation Rules

_Applied during main() execution_

1. **From Contracts**:
   - Each contract file → contract test task [P]
   - Each endpoint → implementation task
2. **From Data Model**:
   - Each entity → model creation task [P]
   - Relationships → service layer tasks
3. **From User Stories**:

   - Each story → integration test [P]
   - Quickstart scenarios → validation tasks

4. **Ordering**:
   - Setup → Tests → Models → Services → Endpoints → Polish
   - Dependencies block parallel execution

## Validation Checklist

_GATE: Checked by main() before returning_

### Constitutional Compliance

- [ ] Test-first development enforced (tests before implementation)
- [ ] Code quality gates configured (static analysis, coverage, security)
- [ ] User experience consistency measures included
- [ ] Performance requirements addressed (<200ms API, <2s frontend)
- [ ] Observability implementation planned (logging, monitoring, metrics)
- [ ] Accessibility requirements included (WCAG 2.1 AA)

### Task Quality

- [ ] All contracts have corresponding tests
- [ ] All entities have model tasks
- [ ] All tests come before implementation
- [ ] Parallel tasks truly independent
- [ ] Each task specifies exact file path
- [ ] No task modifies same file as another [P] task
