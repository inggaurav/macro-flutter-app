# Phase 2 Real Data & Network Foundation Architecture

## Infrastructure Components
1. **ApiClient (`lib/core/networking/api_client.dart`)**: Reusable HTTP client supporting timeout handling, auth header injection, JSON serialization, and typed `ApiFailure` hierarchy.
2. **Local Cache (`lib/core/persistence/local_cache.dart`)**: Offline cache supporting `cacheFirst`, `networkFirst`, and `staleWhileRevalidate` policies.
3. **Realtime Client (`lib/core/realtime/realtime_client.dart`)**: Transport abstraction supporting `connecting`, `connected`, `reconnecting`, `disconnected`, and `failed` lifecycle states.
4. **Relationship Graph (`lib/core/common/entity_relationship.dart`)**: `@`-mention cross-linking between emails, channels, tasks, documents, deals, contacts, and PRs.
5. **Feature Repositories**: Modular interfaces (`InboxRepository`, `ChatRepository`, `DocsRepository`, `TasksRepository`, `CrmRepository`).
