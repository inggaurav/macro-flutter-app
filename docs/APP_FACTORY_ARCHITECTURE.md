# App Factory Core Architecture Blueprint

## Overview
The **App Factory Core** is a generic, reusable Flutter application base that enables rapid deployment of production-grade mobile and desktop clients from GitHub repositories.

```
lib/
├── app/                  # Bootstrap & top-level routing
├── core/                 # Generic reusable infrastructure
│   ├── auth/            # AuthRepository, AuthResult sealed types, token storage
│   ├── storage/         # SecureKeyValueStore (Android Keystore, iOS Keychain)
│   ├── startup/         # StartupService & StartupState pipeline
│   ├── networking/      # ApiClient & ApiFailure typed hierarchy
│   ├── persistence/     # LocalCacheStore & CachePolicy
│   ├── realtime/        # RealtimeClient transport abstraction
│   ├── feature_flags/   # FeatureFlags scoping
│   └── common/          # EntityRef & EntityLink relationship graph
├── features/             # Modular feature slices (Inbox, Chat, Docs, Tasks, CRM, Calls, Profile)
└── integrations/         # Service adapters (Macro, AI, MCP)
```

## Key Capabilities
1. **Platform Secure Storage**: Android Keystore (`EncryptedSharedPreferences`) & iOS Keychain (`KeychainAccessibility`).
2. **Startup Pipeline**: `StartupService` manages runtime config verification, secure storage restore, and route destination determination.
3. **Dynamic Branding**: `AppConfig` controls app title, logo, primary color palette, and environment configurations (`dev`, `staging`, `prod`).
4. **Typed Network Layer**: `ApiClient` handles base URLs, auth header injection, 401 refresh hooks, and typed `ApiFailure` exceptions.
5. **Offline Local Cache**: `LocalCacheStore` implements `cacheFirst`, `networkFirst`, and `staleWhileRevalidate` caching strategies.
6. **Cross-Entity Relationship Graph**: `EntityRef` and `EntityLink` model `@`-mention cross-linking between emails, chat messages, docs, tasks, deals, and PRs.
