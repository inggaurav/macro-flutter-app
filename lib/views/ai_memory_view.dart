import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/workspace_provider.dart';
import '../theme/app_theme.dart';

class AiMemoryView extends StatelessWidget {
  final WorkspaceProvider provider;

  const AiMemoryView({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.auto_awesome, color: AppTheme.accentPurple, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Agents & Unified Team-Level Memory',
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Synthesized automatically from company channels, emails, tasks, and CRDT docs into persistent LLM memory.',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentPurple,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Synthesize Memory Now'),
                  onPressed: () {},
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Category Cards
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.memories.length,
              itemBuilder: (context, index) {
                final mem = provider.memories[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderDark),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.accentPurple.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              mem.category.replaceAll('_', ' ').toUpperCase(),
                              style: const TextStyle(color: AppTheme.accentPurple, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.analytics_outlined, size: 14, color: AppTheme.accentEmerald),
                              const SizedBox(width: 4),
                              Text(
                                '${(mem.confidence * 100).toInt()}% Confidence',
                                style: const TextStyle(color: AppTheme.accentEmerald, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        mem.title,
                        style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mem.summary,
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.source, size: 14, color: AppTheme.textMuted),
                          const SizedBox(width: 6),
                          Text(
                            'Source: ${mem.source}',
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                          ),
                          const Spacer(),
                          Text(
                            'Updated ${DateFormat('h:mm a').format(mem.updatedAt)}',
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
