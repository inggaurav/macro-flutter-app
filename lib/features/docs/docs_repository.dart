import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/macro_service_config.dart';
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
''',
      authorName: 'Alex Rivera',
      lastModified: DateTime.now().subtract(const Duration(hours: 4)),
      tags: ['Architecture', 'Engineering'],
      isPinned: true,
    ),
  ];

  @override
  Future<List<DocumentItem>> fetchDocuments() async {
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
  final MacroServiceConfig _config;
  final String? Function() _tokenProvider;

  MacroDocsRepository({
    MacroServiceConfig? config,
    required String? Function() tokenProvider,
  }) : _config = config ?? MacroServiceConfig.production(),
       _tokenProvider = tokenProvider;

  @override
  Future<List<DocumentItem>> fetchDocuments() async {
    final token = _tokenProvider();
    if (token == null || token.isEmpty) return [];

    try {
      // Verified Upstream Route: GET storageHost/documents
      final response = await http
          .get(
            Uri.parse('${_config.storageHost}/documents'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((item) => DocumentItem.fromJson(item)).toList();
      }
    } catch (_) {}

    return [];
  }

  @override
  Future<DocumentItem> createDocument(
    String title,
    String content,
    String authorName,
  ) async {
    final token = _tokenProvider();
    if (token == null || token.isEmpty) {
      throw Exception('Unauthenticated: Cannot create document without token');
    }

    try {
      // Verified Upstream Route: POST storageHost/documents
      final response = await http
          .post(
            Uri.parse('${_config.storageHost}/documents'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'title': title,
              'content': content,
              'author_name': authorName,
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return DocumentItem.fromJson(data);
      }
    } catch (_) {}

    throw Exception('Failed to create document on storageHost');
  }

  @override
  Future<void> updateDocument(String id, String newContent) async {
    final token = _tokenProvider();
    if (token == null || token.isEmpty) return;

    try {
      // Verified Upstream Route: POST storageHost/documents/{id}/simple_save
      await http
          .post(
            Uri.parse('${_config.storageHost}/documents/$id/simple_save'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'content': newContent}),
          )
          .timeout(const Duration(seconds: 4));
    } catch (_) {}
  }
}
