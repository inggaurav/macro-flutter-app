import '../../models/models.dart';

abstract interface class DocsRepository {
  Future<List<DocumentItem>> fetchDocuments();
  Future<DocumentItem> createDocument(
    String title,
    String content,
    String authorName,
  );
  Future<void> updateDocument(String id, String newContent);
}

class MockDocsRepository implements DocsRepository {
  final List<DocumentItem> _docs = [
    DocumentItem(
      id: 'd1',
      title: 'Macro Architecture & CRDT Engine Protocol',
      content: '''# Macro Architecture & CRDT Engine Protocol

## Multi-Region State Replication
This document specifies the real-time conflict-free replicated data type (CRDT) engine protocol used across Macro workspace clients.

### Key Invariants
1. Causally-ordered event delivery via vector clocks.
2. Local offline mutation journal backed by local persistent storage.
3. Multi-bearer token verification over secure WebSocket transport.
''',
      authorName: 'Alex Rivera',
      lastModified: DateTime.now().subtract(const Duration(hours: 4)),
      tags: ['Architecture', 'Engineering'],
      isPinned: true,
    ),
    DocumentItem(
      id: 'd2',
      title: 'Series A Investment Deck & Financial Projections',
      content: '''# Series A Pitch & Growth Metrics

## Executive Summary
Macro combines email, team chat, shared CRDT documents, and AI Copilot into a unified real-time workspace.

### Q3 Milestones
- 45ms average sync latency across North America and EU edge nodes.
- App Factory foundation for rapid cross-platform Flutter client deployment.
''',
      authorName: 'Sarah Jenkins',
      lastModified: DateTime.now().subtract(const Duration(days: 2)),
      tags: ['Investment', 'Strategy'],
      isPinned: false,
    ),
  ];

  @override
  Future<List<DocumentItem>> fetchDocuments() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _docs;
  }

  @override
  Future<DocumentItem> createDocument(
    String title,
    String content,
    String authorName,
  ) async {
    final doc = DocumentItem(
      id: 'd_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      content: content,
      authorName: authorName,
      lastModified: DateTime.now(),
      tags: ['New'],
    );
    _docs.add(doc);
    return doc;
  }

  @override
  Future<void> updateDocument(String id, String newContent) async {
    final idx = _docs.indexWhere((d) => d.id == id);
    if (idx != -1) {
      final old = _docs[idx];
      _docs[idx] = DocumentItem(
        id: old.id,
        title: old.title,
        content: newContent,
        authorName: old.authorName,
        lastModified: DateTime.now(),
        tags: old.tags,
        versionCount: old.versionCount + 1,
        isPinned: old.isPinned,
      );
    }
  }
}

class MacroDocsRepository implements DocsRepository {
  @override
  Future<List<DocumentItem>> fetchDocuments() async {
    throw UnimplementedError('Macro API Docs endpoints not yet configured.');
  }

  @override
  Future<DocumentItem> createDocument(
    String title,
    String content,
    String authorName,
  ) async {
    throw UnimplementedError('Macro API Docs endpoints not yet configured.');
  }

  @override
  Future<void> updateDocument(String id, String newContent) async {
    throw UnimplementedError('Macro API Docs endpoints not yet configured.');
  }
}
