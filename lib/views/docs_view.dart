import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/workspace_provider.dart';
import '../theme/app_theme.dart';
import 'mobile/doc_detail_screen.dart';

class DocsView extends StatelessWidget {
  final WorkspaceProvider provider;

  const DocsView({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    final selectedDoc = provider.documents.firstWhere(
      (d) => d.id == provider.selectedDocId,
      orElse: () => provider.documents.first,
    );

    final docsListWidget = Container(
      width: isMobile ? double.infinity : 280,
      decoration: BoxDecoration(
        border: isMobile ? null : const Border(right: BorderSide(color: AppTheme.borderDark)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.borderDark)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Docs & Specs',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.note_add_outlined, size: 20, color: AppTheme.primaryIndigo),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: provider.documents.length,
              itemBuilder: (context, index) {
                final doc = provider.documents[index];
                final isSelected = !isMobile && doc.id == selectedDoc.id;

                return ListTile(
                  selected: isSelected,
                  selectedTileColor: AppTheme.primaryIndigo.withOpacity(0.15),
                  leading: Icon(
                    doc.isPinned ? Icons.push_pin : Icons.description_outlined,
                    color: isSelected ? AppTheme.primaryIndigo : AppTheme.textMuted,
                    size: 18,
                  ),
                  title: Text(
                    doc.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Text(
                    'Modified ${DateFormat('MMM d').format(doc.lastModified)} • v${doc.versionCount}',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                  ),
                  onTap: () {
                    provider.selectDoc(doc.id);
                    if (isMobile) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DocDetailScreen(document: doc),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );

    if (isMobile) {
      return Scaffold(
        backgroundColor: AppTheme.bgDark,
        body: docsListWidget,
      );
    }

    // Desktop View
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Row(
        children: [
          docsListWidget,
          Expanded(
            child: Column(
              children: [
                // Toolbar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppTheme.borderDark)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Author: ${selectedDoc.authorName}',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accentEmerald.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.circle, size: 6, color: AppTheme.accentEmerald),
                            SizedBox(width: 4),
                            Text(
                              'CRDT LIVE SYNC',
                              style: TextStyle(color: AppTheme.accentEmerald, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.surfaceLightDark,
                          foregroundColor: AppTheme.accentPurple,
                          side: const BorderSide(color: AppTheme.borderDark),
                        ),
                        icon: const Icon(Icons.auto_awesome, size: 16),
                        label: const Text('AI Rewrite & Format'),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                // Canvas Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedDoc.title,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: selectedDoc.tags.map((t) {
                            return Chip(
                              backgroundColor: AppTheme.surfaceLightDark,
                              side: const BorderSide(color: AppTheme.borderDark),
                              label: Text(t, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),
                        SelectableText(
                          selectedDoc.content,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
