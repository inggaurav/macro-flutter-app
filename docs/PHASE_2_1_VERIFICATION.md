# Phase 2.1 Runtime Integration & Hardening Verification

## Implementation Reality Audit

### REAL IMPLEMENTATIONS:
- **Chat & Inbox UI Migration**: `ChatView`, `ChannelChatScreen`, `InboxView`, and `EmailDetailScreen` consume `ChatController` and `InboxController` directly.
- **WorkspaceProvider Reduction**: Removed duplicated `emails` and `chatMessages` state from `WorkspaceProvider`.
- **Stale-While-Revalidate Caching**: `ChatController` and `InboxController` load cached JSON immediately, refresh from repository, and persist to `SharedPreferencesLocalCacheStore`.
- **Workspace-Scoped Cache Keys**: Keys are workspace-scoped (`workspace:<workspaceId>:chat:channels`, `workspace:<workspaceId>:chat:messages:<channelId>`, `workspace:<workspaceId>:inbox:threads`).
- **Explicit Model Serialization**: `EmailThread`, `ChatChannel`, and `ChatMessage` implement explicit `toJson()` and `fromJson()` methods.
- **Single-Flight 401 Refresh Interceptor**: `ApiClient` shares a single refresh future across concurrent 401 requests using `Future<bool>? _refreshFuture`.
- **PATCH Support**: `ApiClient.patch()` implemented with full header, timeout, and refresh interceptor integration.
- **Auth Token Provider Adapter**: `AuthRepositoryTokenProvider` bridges `AuthRepository` and `ApiClient`.
- **Realtime Lifecycle Wiring**: `ChatController` subscribes to `realtimeClient.eventStream` and `realtimeClient.stateStream` with clean stream disposal.
- **Harden Test Suite**: Comprehensive unit tests for `ApiClient`, `ChatController`, `InboxController`, `LocalCacheStore`, `SecureKeyValueStore`, and model serialization.

### MOCK / DEV ADAPTERS:
- **Macro API Endpoints**: Production API backend URL endpoints (`MacroChatRepository`, `MacroInboxRepository`, etc.).
- **Auth Token Server Exchange**: Token exchange endpoint on `AuthRepository.refreshSession()`.
- **Realtime Transport**: `MockRealtimeClient` simulates WebSocket connection and message events.
- **AI Reply Generation**: Simulated AI draft response delay.

### PLANNED NEXT PHASE:
- **Phase 3**: Premium UI/UX Redesign using Apple/HIG, Origin/shadcn, GlassKit, Componentry, Scroll World, Taste, and design-DNA principles.
