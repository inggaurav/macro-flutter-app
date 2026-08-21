# Phase 2 Real Data & Network Foundation Architecture

## Infrastructure Components
1. **ApiClient (`lib/core/networking/api_client.dart`)**: Reusable HTTP client supporting timeout handling, auth header injection, JSON serialization, single 401 refresh token hook, and typed `ApiFailure` hierarchy.
2. **Fail-Closed Secure Storage (`lib/core/storage/secure_key_value_store.dart`)**: `PlatformSecureStorageService` backed by Android Keystore / iOS Keychain. Throws `SecureStorageException` on error to fail closed.
3. **Persistent Local Cache (`lib/core/persistence/local_cache.dart`)**: `SharedPreferencesLocalCacheStore` implementing `cacheFirst`, `networkFirst`, and `staleWhileRevalidate` policies.
4. **Realtime Client (`lib/core/realtime/realtime_client.dart`)**: Transport abstraction supporting `connecting`, `connected`, `reconnecting`, `disconnected`, and `failed` lifecycle states.
5. **Relationship Graph (`lib/core/common/entity_relationship.dart`)**: `@`-mention cross-linking between emails, channels, tasks, documents, deals, contacts, and PRs.
6. **Canonical Domain Models (`lib/features/.../domain/`)**: Separated domain models (`EmailThread`, `ChatChannel`, `ChatMessage`, `DocumentItem`, `TaskItem`, `CrmDeal`).
7. **Feature Repositories**: Complete clean repository contracts and mock/macro implementations for all 7 features:
   - `InboxRepository`
   - `ChatRepository`
   - `DocsRepository`
   - `TasksRepository`
   - `CrmRepository`
   - `AgentRepository`
   - `CallsRepository`
8. **WorkspaceProvider Decomposition**: `ChatController` and `InboxController` managing feature state independently.
