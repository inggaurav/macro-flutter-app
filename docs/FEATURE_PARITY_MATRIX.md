# MACRO FLUTTER — FEATURE PARITY MATRIX

Audit Date: 2026-08-21
Branch: real-integrations-reset

| Feature / Domain | Upstream Macro | Flutter UI | Flutter API Adapter | Connected Runtime | Tested | Remaining Work |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Authentication & Tokens** | ✅ Supported (`auth-service.macro.com`) | ✅ Ready | ✅ `MacroAuthRepository` | ⚠️ Bearer Token | ✅ Tests Pass | Consumer Mobile OAuth PKCE |
| **Gmail Link OAuth** | ✅ Supported (`POST /v1/link/gmail`) | ✅ Ready | ✅ `MacroInboxRepository.linkGmail()` | ⚠️ Configured Endpoint | ✅ Unit Tests | Server OAuth Callback Webview |
| **Connected Mailboxes** | ✅ Supported (`email-service.macro.com`) | ✅ Ready | ✅ `MacroInboxRepository` | ⚠️ Live Service | ✅ Unit Tests | Multi-account filter |
| **Unified Email Inbox** | ✅ Supported (`email-service.macro.com`) | ✅ Ready | ✅ `MacroInboxRepository` | ⚠️ Live Service | ✅ Unit Tests | Paginated Cursor Infinite Scroll |
| **Email Threads & Send** | ✅ Supported | ✅ Ready | ✅ `MacroInboxRepository` | ⚠️ Live Service | ✅ Unit Tests | Rich Text HTML Mail Composer |
| **Native Macro Channels** | ✅ Supported (`/v1/channels`) | ✅ Ready | ✅ `MacroChatRepository` | ⚠️ Live Service | ✅ Unit Tests | Group DM Admin Controls |
| **Realtime Gateway** | ✅ Supported (`connection-gateway.macro.com`) | ✅ Ready | ✅ `MacroRealtimeClient` | ⚠️ Live Gateway | ✅ Unit Tests | Auto Vector Clock Re-sync |
| **AI Cognition Chat & Stream** | ✅ Supported (`document-cognition.macro.com`) | ✅ Ready | ✅ `MacroAgentRepository` | ⚠️ Live Service | ✅ Unit Tests | Stream Token Buffer |
| **AI Model Registry** | ✅ Supported | ✅ Ready | ✅ `WorkspaceProvider` | ⚠️ Live Models | ✅ Unit Tests | Dynamic Endpoint Model Discovery |
| **Slack MCP Integration** | ✅ Supported (Server-side MCP) | ✅ Ready | ⚠️ Gateway Architecture | ⚠️ Server-side OAuth | ✅ Unit Tests | Server MCP Proxy Deployment |
| **Docs & Storage** | ✅ Supported (`cloud-storage.macro.com`) | ✅ Ready | ✅ `MacroDocsRepository` | ⚠️ Live Service | ✅ Unit Tests | Full CRDT Yjs WebSockets |
| **Tasks & Kanban** | ✅ Supported | ✅ Ready | ✅ `MacroTasksRepository` | ⚠️ Live Service | ✅ Unit Tests | Assignee Filter |
| **CRM Deals & Companies** | ✅ Supported (`contacts.macro.com`) | ✅ Ready | ✅ `MacroCrmRepository` | ⚠️ Live Service | ✅ Unit Tests | Custom Field Definitions |
| **Call Records & Summaries** | ✅ Supported | ✅ Ready | ✅ `MacroCallsRepository` | ⚠️ Live Service | ✅ Unit Tests | Live Audio Stream Integration |
| **File Storage & Attachments** | ✅ Supported (`static-file-service.macro.com`) | ✅ Ready | ✅ Native Adapters | ⚠️ Live Service | ✅ Unit Tests | File Downloader Cache |
| **GitHub / PR Blocks** | ✅ Supported | ✅ Ready | ⚠️ Gateway Architecture | ⚠️ Server-side OAuth | ✅ Unit Tests | Direct Webhook Listener |
| **Global Search (Ctrl+K)** | ✅ Supported (`properties.macro.com`) | ✅ Ready | ✅ `CommandPalette` | ⚠️ Live Service | ✅ Unit Tests | Search Index Caching |
| **Entity Relationship Graph** | ✅ Supported | ✅ Ready | ✅ `EntityRelationship` | ⚠️ Models | ✅ Unit Tests | Graph Database Visualizer |
