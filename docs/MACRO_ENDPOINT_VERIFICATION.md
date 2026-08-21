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
| `GoogleService.checkConnectionStatus` | `GET` | `${authHost}/link/gmail/status` | none | `{ connected/status, email }` | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `GoogleService.initiateGoogleSso` | `POST` | `${authHost}/login/sso` | `{ provider, client_type, redirect_uri }` | `{ authorization_url/url }` | No prior token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `GoogleService.initiateGoogleSso` fallback | `GET` | `${authHost}/login/sso?provider=google_gmail` | query only | external auth page | No prior token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `GoogleService.initiateGoogleOAuth` | `POST` | `${authHost}/link/gmail` | none | `{ authorization_url }` | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `GoogleService.disconnectGoogle` | `DELETE` | `${authHost}/link/gmail` | none | none expected | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `GoogleService.fetchCalendarEvents` | `GET` | `${emailHost}/email/calendar/events` | none | array of calendar event JSON | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroInboxRepository.fetchEmails` | `GET` | `${emailHost}/email/threads/previews/cursor/inbox?limit=25` | query only | array of email thread JSON | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroInboxRepository.markAsRead` | `POST` | `${emailHost}/email/threads/{id}/seen` | none | success status | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroInboxRepository.generateAiReply` | `POST` | `${cognitionHost}/email/reply-draft` | `{ email_id }` | `{ draft/text/content }` | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroInboxRepository.linkGmail` | `POST` | `${authHost}/link/gmail` | none | `{ authorization_url }` | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroChatRepository.fetchChannels` | `GET` | `${storageHost}/comms/channels` | none | array of channel JSON | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroChatRepository.fetchMessages` | `GET` | `${storageHost}/channels/{channelId}/messages` | path channel id | array of message JSON | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroChatRepository.sendMessage` | `POST` | `${storageHost}/channels/{channelId}/messages` | `{ text, is_agent }` | message JSON | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroDocsRepository.fetchDocuments` | `GET` | `${storageHost}/documents` | none | array of document JSON | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroDocsRepository.createDocument` | `POST` | `${storageHost}/documents` | `{ title, content }` | document JSON | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroDocsRepository.saveDocument` | `POST` | `${storageHost}/documents/{id}/simple_save` | `{ content }` | success status | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroTasksRepository.fetchTasks` | `GET` | `${storageHost}/tasks` | none | array of task JSON | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroTasksRepository.updateTaskStatus` | `POST` | `${storageHost}/tasks/{taskId}/status` | `{ status }` | success status | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroTasksRepository.createTask` | `POST` | `${storageHost}/documents/create_task` | `{ title, description, priority }` | task JSON | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroCrmRepository.fetchDeals` | `GET` | `${contactsHost}/v1/deals` | none | array of deal JSON | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroCrmRepository.updateDealStage` | `PATCH` | `${contactsHost}/v1/deals/{dealId}` | `{ stage }` | success status | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroAgentRepository.fetchMemory` | `GET` | `${cognitionHost}/memory` | none | array of memory JSON | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroAgentRepository.sendMessage` | `POST` | `${cognitionHost}/stream/chat/message` | chat message payload | AI response JSON | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroCallsRepository.fetchCalls` | `GET` | `${storageHost}/calls` | none | array of call JSON | Bearer token | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |
| `MacroRealtimeClient.connect` | `WS` | `${connectionGateway}?token={token}` | token query | realtime event stream | Bearer-equivalent token query | Not present in this repo | `IMPLEMENTED_UNVERIFIED` |

## Known Endpoint Truth Risks

1. Comments in Dart saying "Verified Upstream Route" are not sufficient evidence.
2. Several repositories return empty lists when a backend call fails, which hides real integration failures.
3. OAuth routes are especially high-risk until traced to upstream server code and mobile callback/deep-link contracts.
4. `POST ${storageHost}/documents/create_task` is suspiciously cross-domain and needs upstream confirmation.
5. `POST ${cognitionHost}/stream/chat/message` is named as a stream route, but the Flutter implementation expects one JSON response.

## Required Verification Workflow

For each row above:

1. Locate upstream OpenAPI/backend/client source.
2. Record request and response schema exactly.
3. Add a contract or integration test using the real schema.
4. Smoke-test with a real authenticated user.
5. Replace `IMPLEMENTED_UNVERIFIED` with `VERIFIED_REAL` only after the full path passes.
