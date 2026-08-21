# Macro Endpoint Verification

This document records every production-facing endpoint currently referenced by the Flutter client. At this phase, repository methods are treated as `IMPLEMENTED_UNVERIFIED` unless they can be traced to Macro upstream OpenAPI/backend/client source and verified with a real authenticated smoke test.

## Verification Fields

Each endpoint must eventually include:

- Flutter method
- HTTP method
- Exact URL/path
- Macro generated SDK/OpenAPI method
- Upstream source file
- Request schema
- Response schema
- Auth requirement
- Verification status

## Endpoint Inventory

| Flutter method | HTTP | URL/path | Request schema | Response schema | Auth | Upstream source / SDK trace | Status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `AuthRepositoryImpl.loginWithPassword` | `POST` | `${authHost}/login/password` | `{ email, password }` | `{ token/access_token }` then `/user/me` | No prior token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `AuthRepositoryImpl.signup` | `POST` | `${authHost}/signup` | `{ name, email, password }` | `{ token/access_token }` then `/user/me` | No prior token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `AuthRepositoryImpl._validateTokenWithServer` | `GET` | `${authHost}/user/me` | none | user profile JSON | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `GoogleService.buildGoogleSsoUri/initiateGoogleSso` | `GET` | `${authHost}/login/sso?idp_name=google_gmail&is_mobile=true&original_url=macro://login` | query only | HTTP redirect to identity provider | No prior token | Contract asserted by unit test; upstream source not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `AuthRepositoryImpl.redeemMobileSessionCode` | `GET` | `${authHost}/session/login/{session_code}` | path session code | `{ access_token, refresh_token }` | One-time session code | Contract asserted by unit test; upstream source not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `AuthRepositoryImpl.refreshSession` | `POST` | `${authHost}/jwt/refresh` | headers: `Authorization`, `x-macro-refresh-token` | `{ access_token, refresh_token }` | Access + refresh token | Contract asserted by unit test; upstream source not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `GoogleService.fetchGoogleAccounts` | `GET` | `${emailHost}/email/links` | none | `{ items: email link[] }` | Bearer token | Contract asserted by unit test; upstream source not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `GoogleService.fetchGmailReauthenticationRequired` | `GET` | `${authHost}/link/gmail/status` | none | `{ reauthentication_required }` | Bearer token | Contract asserted by unit test; upstream source not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `GoogleService.initiateGoogleOAuth` | `POST` | `${authHost}/link/gmail?scopes=gmail_and_calendar&original_url=macro://login` | query + empty body | `{ authorization_url/url }` | Bearer token | Contract shape in adapter; upstream source not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `GoogleService.disconnectGoogle` | `DELETE` | `${emailHost}/email/links/{link_id}` | path link id | none expected | Bearer token | Contract shape in adapter; upstream source not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `GoogleService.fetchCalendars` | `GET` | `${emailHost}/calendar/calendars` | none | `{ items: calendars[] }` | Bearer token | Contract asserted by unit test; upstream source not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `GoogleService.fetchCalendarEvents` | `GET` | `${storageHost}/calendar-events` | optional range query | `{ items: event occurrences[] }` | Bearer token | Contract asserted by unit test; upstream source not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroInboxRepository.fetchInboxPage` | `GET` | `${emailHost}/email/threads/previews/cursor/inbox?limit=25` | query/cursor | `{ items, next_cursor }` | Bearer token | Contract asserted by unit test; upstream source not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroInboxRepository.markAsRead` | `POST` | `${emailHost}/email/threads/{id}/seen` | none | success status | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroInboxRepository.generateAiReply` | `POST` | `${cognitionHost}/email/reply-draft` | `{ email_id }` | `{ draft/text/content }` | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroInboxRepository.linkGmail` | `POST` | `${authHost}/link/gmail?scopes=gmail_and_calendar&original_url=macro://login` | query + empty body | `{ authorization_url/url }` | Bearer token | Contract shape in adapter; upstream source not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroChatRepository.fetchChannelsPage` | `GET` | `${storageHost}/comms/channels` | optional cursor | `{ items, next_cursor }` | Bearer token | Contract asserted by unit test; upstream source not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroChatRepository.fetchMessagesPage` | `GET` | `${storageHost}/channels/{channelId}/messages` | path channel id + optional cursor | `{ items, next_cursor, previous_cursor }` | Bearer token | Contract asserted by unit test; upstream source not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroChatRepository.sendMessage` | `POST` | `${storageHost}/channels/{channelId}/message` | `{ content, mentions, attachments, thread_id, nonce }` | message JSON | Bearer token | Contract asserted by unit test; upstream source not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroDocsRepository.fetchDocuments` | `GET` | `${storageHost}/documents` | none | array of document JSON | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroDocsRepository.createDocument` | `POST` | `${storageHost}/documents` | `{ title, content }` | document JSON | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroDocsRepository.saveDocument` | `POST` | `${storageHost}/documents/{id}/simple_save` | `{ content }` | success status | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroTasksRepository.fetchTasks` | `GET` | `${storageHost}/tasks` | none | array of task JSON | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroTasksRepository.updateTaskStatus` | `POST` | `${storageHost}/tasks/{taskId}/status` | `{ status }` | success status | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroTasksRepository.createTask` | `POST` | `${storageHost}/documents/create_task` | `{ title, description, priority }` | task JSON | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroCrmRepository.fetchDeals` | `GET` | `${contactsHost}/v1/deals` | none | array of deal JSON | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroCrmRepository.updateDealStage` | `PATCH` | `${contactsHost}/v1/deals/{dealId}` | `{ stage }` | success status | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroAgentRepository.fetchMemory` | `GET` | `${cognitionHost}/memory` | none | array of memory JSON | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroAgentRepository.startCopilotStream` | `POST` | `${cognitionHost}/stream/chat/message` | `{ content, chat_id?, attachments }` | `{ stream_id, chat_id?, message_id? }` | Bearer token | Contract asserted by unit test; gateway stream consumption still pending | `PARTIAL` |
| `MacroCallsRepository.fetchCalls` | `GET` | `${storageHost}/calls` | none | array of call JSON | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroRealtimeClient.connect` | `WS` | `${connectionGateway}?token={token}` | token query | realtime event stream | Bearer-equivalent token query | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |

## Known Endpoint Truth Risks

1. Comments in Dart saying "Verified Upstream Route" are not sufficient evidence.
2. Several non-audited repositories still return empty lists when a backend call fails, especially Tasks, Docs, CRM, Calls, and some controller cache reads.
3. OAuth routes are high-risk until traced to upstream server code and validated by a real S24 remote smoke test.
4. `POST ${storageHost}/documents/create_task` is suspiciously cross-domain and needs upstream confirmation.
5. `POST ${cognitionHost}/stream/chat/message` now parses stream metadata, but gateway event assembly is still pending.

## Required Verification Workflow

For each row above:

1. Locate upstream OpenAPI/backend/client source.
2. Record request and response schema exactly.
3. Add a contract or integration test using the real schema.
4. Smoke-test with a real authenticated user.
5. Replace `IMPLEMENTED_UNVERIFIED` with `VERIFIED_REAL` only after the full path passes.
