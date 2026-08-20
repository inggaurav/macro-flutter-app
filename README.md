# Macro Unified Workspace - Flutter Application 🚀

A cross-platform Flutter application implementation converting [macro-inc/macro](https://github.com/macro-inc/macro)—the unified workspace for teams: email, team chat, collaborative docs, task boards, sales CRM, AI shared memory, and live call transcription.

---

## 🌟 Features

- 📧 **Inbox & Email Client**: Unified thread inbox with `@`-linked company tags, starred flags, and AI Reply Draft generation.
- 💬 **Team Chat & Channels**: Slack-style channels (`#general`, `#engineering`, `#sales-deals`, `#ai-agents-memory`), real-time messages with AI Agent auto-responses, code snippets, and `@`-mention shortcuts.
- 📝 **Docs & Wiki**: Real-time collaborative CRDT document editor with tag chips, version history timeline, and AI rewrite & formatting assistant.
- 📋 **Engineering Task Board**: 4-Column Kanban (`To Do`, `In Progress`, `In Review`, `Done`) with priority badges (`Urgent`, `High`, `Medium`), assignees, and due dates.
- 💼 **Sales CRM & Deal Pipeline**: Stage pipeline (`Proposal`, `Negotiation`, `Closed Won`) with ARR monetary metrics and bidirectional conversation history links.
- 🧠 **AI Memory Synthesis**: Persistent team memory synthesized daily from email, chat, docs, and CRM across GPT-4o, Claude 3.5 Sonnet, Gemini 1.5 Pro, and DeepSeek V3.
- 📞 **Calls & Transcription**: Meeting call room interface with active speaker tiles, live AI transcription feed, and automated call summary notes.

---

## 📸 Screenshots & Architecture

Dark Glassmorphism Theme (Material 3 + Inter Typography) designed for Web, macOS, Windows, iOS, and Android.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (`>= 3.12.0`)

### Installation & Run

```bash
# Clone the repository
git clone https://github.com/inggaurav/macro-flutter-app.git
cd macro-flutter-app

# Install dependencies
flutter pub get

# Run on Web / Desktop / Mobile
flutter run
```

### Build Android Mobile Package (APK)

```bash
flutter build apk --debug
```

---

## 🛠️ Stack & Dependencies

- **Framework**: Flutter (Material 3)
- **State Management**: Provider (`ChangeNotifier`)
- **Typography**: Google Fonts (Inter)
- **Utilities**: `intl`, `uuid`, `cupertino_icons`
