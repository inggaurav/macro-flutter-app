# Macro Flutter App & App Factory Core

A production-quality native Flutter client for **Macro Unified Workspace** built on top of a reusable **App Factory Core architecture**.

## Architecture & Implementation Status

### ✅ IMPLEMENTED (Real Infrastructure & Feature Repositories)
- **Platform Secure Storage**: Android Keystore & iOS Keychain token storage (`PlatformSecureStorageService` throwing `SecureStorageException` on failure to fail-closed).
- **Startup Engine**: `StartupService` manages runtime config verification, secure storage restore, and route destination.
- **App Factory Engine**: Runtime & build-time `AppConfig` supporting dynamic app name, logo, primary color palette, and environment configurations (`dev`, `staging`, `prod`).
- **Typed Authentication Pipeline**: `AuthRepository` with sealed `AuthResult` types (`AuthSuccess`, `AuthInvalidCredentials`, `AuthNetworkFailure`, `AuthServerFailure`, `AuthValidationFailure`). Distinct `signup()` and `requestPasswordReset()` contracts.
- **Typed Network Client with Refresh Interceptor**: `ApiClient` supporting timeouts, JSON serialization, auth header injection, single 401 token refresh attempt hook with storm prevention lock, and typed `ApiFailure` hierarchy.
- **Persistent Local Cache**: `SharedPreferencesLocalCacheStore` implementing `LocalCacheStore` alongside `InMemoryLocalCacheStore` for test suites.
- **Realtime Transport**: `RealtimeClient` supporting connection states (`connecting`, `connected`, `reconnecting`, `disconnected`, `failed`).
- **Cross-Entity Relationship Graph**: `EntityRef` and `EntityLink` supporting `@`-mention cross-linking between emails, messages, tasks, documents, deals, and PRs.
- **Modular Feature Repositories**: Complete clean repository contracts and mock/macro implementations for ALL 7 features:
  - `InboxRepository` (`MockInboxRepository`, `MacroInboxRepository`)
  - `ChatRepository` (`MockChatRepository`, `MacroChatRepository`)
  - `DocsRepository` (`MockDocsRepository`, `MacroDocsRepository`)
  - `TasksRepository` (`MockTasksRepository`, `MacroTasksRepository`)
  - `CrmRepository` (`MockCrmRepository`, `MacroCrmRepository`)
  - `AgentRepository` (`MockAgentRepository`, `MacroAgentRepository`)
  - `CallsRepository` (`MockCallsRepository`, `MacroCallsRepository`)
- **WorkspaceProvider Decomposition**: Extracted dedicated `ChatController` and `InboxController` for feature state management.
- **Mobile & Desktop Shell**: Adaptive desktop sidebar & top header, responsive mobile top AppBar & 5-destination bottom navigation bar with push/pop single-screen detail views.
- **GitHub Actions CI**: Automated CI workflow using Flutter `stable` channel.

---

## Verification Commands
```bash
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug
```
