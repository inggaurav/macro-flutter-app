# Macro Flutter App & App Factory Core

A production-quality native Flutter client for **Macro Unified Workspace** built on top of a reusable **App Factory Core architecture**.

## Architecture & Implementation Status

### ✅ IMPLEMENTED (Real Infrastructure)
- **Platform Secure Storage**: Android Keystore & iOS Keychain token storage (`SecureKeyValueStore`).
- **Startup Engine**: `StartupService` manages runtime config verification, secure storage restore, and route destination.
- **App Factory Engine**: Runtime & build-time `AppConfig` supporting dynamic app name, logo, primary color palette, and environment configurations (`dev`, `staging`, `prod`).
- **Typed Authentication Pipeline**: `AuthRepository` with sealed `AuthResult` types (`AuthSuccess`, `AuthInvalidCredentials`, `AuthNetworkFailure`, `AuthServerFailure`, `AuthValidationFailure`). Distinct `signup()` and `requestPasswordReset()` contracts.
- **Typed Network Client**: `ApiClient` with auth header injection, timeout handling, secret-safe logging, and typed `ApiFailure` hierarchy.
- **Local Persistence & Offline Cache**: `LocalCacheStore` supporting `cacheFirst`, `networkFirst`, and `staleWhileRevalidate` policies.
- **Realtime Transport**: `RealtimeClient` supporting connection states (`connecting`, `connected`, `reconnecting`, `disconnected`).
- **Cross-Entity Relationship Graph**: `EntityRef` and `EntityLink` supporting `@`-mention cross-linking between emails, messages, tasks, documents, deals, and PRs.
- **Mobile & Desktop Shell**: Adaptive desktop sidebar & top header, responsive mobile top AppBar & 5-destination bottom navigation bar with push/pop single-screen detail views.
- **GitHub Actions CI**: Automated CI workflow using Flutter `stable` channel.

### 🛠️ DEVELOPMENT ADAPTERS (Mock Data Layer)
- **Feature Repositories**: `MockInboxRepository`, `MockChatRepository`, `MockDocsRepository`, `MockTasksRepository`, `MockCrmRepository` (Ready to be swapped with `MacroApiXRepository` adapters).

### 🔮 PLANNED (Next Phase Backend Vertical Slices)
- Real WebSocket backend connection to Macro server.
- Production CRDT document collaboration engine.
- Real Gmail OAuth / IMAP sync.
- Production MCP Swarm integration.

---

## Verification Commands
```bash
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug
```
