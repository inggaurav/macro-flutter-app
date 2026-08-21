# Phase 4.0 Production Integration Audit

This audit freezes the current Macro Flutter branch before any Mr Fox white-label work. The goal is to separate screens that exist from features that are truthfully verified against a real backend.

## Baseline Snapshot

| Item | Value |
| --- | --- |
| Branch | `real-integrations-google-parity-v2` |
| Baseline HEAD | `40a17a8e3004ca658c82859fa9141c1af0703038` |
| Flutter | `3.44.8` stable |
| Dart | `3.12.2` |
| Test baseline | `flutter test` passed, 24/24 |
| Analyze baseline before repair | 61 issues, then 3 after automated fixes |
| Analyze target after repair | 0 issues |
| Upstream Macro SHA/contracts | Not present in this repository; endpoint claims remain unverified until traced to OpenAPI/backend/source evidence |

## Production Hosts

| Service | Host |
| --- | --- |
| Auth | `https://auth-service.macro.com` |
| Storage | `https://cloud-storage.macro.com` |
| Email | `https://email-service.macro.com` |
| Cognition | `https://document-cognition.macro.com` |
| Notifications | `https://notifications.macro.com` |
| Connection Gateway | `wss://connection-gateway.macro.com` |
| Contacts | `https://contacts.macro.com` |
| Search / Properties | `https://properties.macro.com` |
| Static Files | `https://static-file-service.macro.com` |
| Scheduled Agents | `https://agent-schedule.macro.com` |

## Baseline Dirty Files Before This Phase

These files were already modified before the Phase 4.0 audit/repair pass began:

- `android/.kotlin/sessions/kotlin-compiler-9848080095395737322.salive` deleted local compiler session
- `lib/config/macro_service_config.dart`
- `lib/core/auth/auth_repository.dart`
- `lib/main.dart`
- `lib/repositories/auth_repository.dart`
- `test/contracts/api_route_contracts_test.dart`

## Classification Legend

- `VERIFIED_REAL`: Proven by a real authenticated smoke test and upstream contract/source trace.
- `IMPLEMENTED_UNVERIFIED`: Dart implementation exists but is not traced to upstream source and smoke-tested.
- `PARTIAL`: Some UI/data path exists, but required production behavior is incomplete.
- `MOCK`: Mock repository/demo data is the primary implemented behavior.
- `BROKEN`: Known failure or gate blocker.
- `PLANNED`: No production implementation yet.

## Feature Audit

| Area | Status | Current Evidence | Production Gap |
| --- | --- | --- | --- |
| Authentication: password/token | `PARTIAL` | `AuthRepositoryImpl` has password login, token validation, restore, logout. Local dev auth exists. | Real auth endpoints are not traced to upstream OpenAPI/backend evidence. Refresh rotation, revoke semantics, and failure UX need verification. |
| Authentication: Google | `PARTIAL` | `GoogleService.initiateGoogleSso()` and Gmail link methods exist. | Mobile OAuth PKCE/deep link callback, one-time code exchange, cancellation, malformed callback, and session code expiry are not implemented end-to-end. |
| Authentication: refresh | `PARTIAL` | `refreshSession()` validates current token. | No refresh token storage, rotation, or refresh endpoint contract is implemented. |
| Authentication: logout | `IMPLEMENTED_UNVERIFIED` | Local token/user storage is cleared. | Backend revoke/logout is not called or verified. |
| Workspace | `PARTIAL` | `WorkspaceProvider` stores selected UI tab and drawer state. Cache keys include a hardcoded/default workspace id in controllers. | No real workspace lifecycle, memberships, roles, invites, workspace switcher, permissions, or current workspace persistence. |
| Gmail accounts | `PARTIAL` | Gmail status and link calls exist. | Multiple accounts, account filter, reauth, labels, attachments, and real account discovery are not verified. |
| Gmail threads/messages | `IMPLEMENTED_UNVERIFIED` | `MacroInboxRepository.fetchEmails()` calls thread preview route. | Full message load, pagination, reply/send/forward, read state persistence, attachment handling, and smoke tests are pending. |
| Gmail drafts/send | `PLANNED` | AI reply draft endpoint exists. | No production compose/send/draft lifecycle verified. |
| Calendar | `PARTIAL` | `GoogleService.fetchCalendarEvents()` fetches event list. | Calendar list, create/update/delete, attendees, RSVP, reminders, recurrence, and account grouping are missing. |
| Contacts | `PLANNED` | Contacts host is configured. | No connected Google contacts repository/UI verified. |
| Chat | `IMPLEMENTED_UNVERIFIED` | Channels/messages/send repository methods exist. | Pagination, channel membership, group admin controls, and smoke tests are not verified. |
| Realtime | `PARTIAL` | `MacroRealtimeClient` exists with heartbeat/reconnect and controller event hooks. | Actual subscription auth, event schemas, channel/doc/inbox integration, and resync are not verified. |
| Docs | `PARTIAL` | Document list/create/simple save exists. | Real collaboration, CRDT/Yjs websocket protocol, conflict handling, and rich editor persistence are not done. |
| Tasks | `PARTIAL` | Fetch, create, and status update methods exist. | Full CRUD, assignee model, filters, custom fields, permissions, and smoke tests are pending. |
| CRM | `PARTIAL` | Deals fetch/update exists. | Contacts/companies, full pipeline CRUD, field definitions, and Google contacts integration are missing. |
| AI | `PARTIAL` | Memory fetch and chat message endpoint exist. | Streaming token handling, contextual source attribution, cancellation, retry, and real smoke tests are missing. |
| Memory | `IMPLEMENTED_UNVERIFIED` | Memory repository endpoint exists. | Persistence contract and source ownership are not verified. |
| Calls | `PARTIAL` | Calls list endpoint exists. | Rooms, live audio, recording, transcripts, permissions, and storage are missing. |
| Files | `PLANNED` | Static file host is configured. | Upload/download/cache, permissions, previews, and attachment integration are not implemented. |
| Search | `PLANNED` | Search/properties host is configured. | Global/entity search repository, indexing, caching, and UI are not implemented. |
| Notifications | `PLANNED` | Notifications host is configured. | Push/local notifications, inbox source, device registration, and settings are missing. |
| Slack | `PLANNED` | No adapter found. | Auth and data integration are missing. |
| GitHub | `PLANNED` | PR entity type exists in the relationship graph model. | Auth, repo/PR/issues data, and linking are missing. |

## Immediate Repair Gate

| Gate | Result |
| --- | --- |
| Format | Pending final run |
| Analyze | Target 0 issues |
| Test | Target 24/24+ pass |
| Debug APK | Pending final run |
| CI workflow | Java setup corrected to `actions/setup-java@v4` |

## Non-Negotiable Next Rules

1. Do not white-label to Mr Fox until auth, workspace, and endpoint truth are stable.
2. A route string in Dart is not enough to mark a feature `VERIFIED_REAL`.
3. Production adapters must surface backend failures instead of silently returning empty data.
4. Every feature should move through contract, DTO, repository, controller, UI, cache, error handling, tests, smoke test, then `VERIFIED_REAL`.
