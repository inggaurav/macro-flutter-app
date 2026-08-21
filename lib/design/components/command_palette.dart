import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workspace_provider.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';

class CommandPalette extends StatefulWidget {
  const CommandPalette({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => const CommandPalette(),
    );
  }

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workspace = Provider.of<WorkspaceProvider>(context, listen: false);

    final actions = [
      _CommandAction(
        title: 'Open Inbox & Email Threads',
        category: 'NAVIGATION',
        icon: Icons.inbox_outlined,
        onSelect: () => workspace.setTab(WorkspaceTab.inbox),
      ),
      _CommandAction(
        title: 'Open Team Channels & Chat',
        category: 'NAVIGATION',
        icon: Icons.chat_bubble_outline,
        onSelect: () => workspace.setTab(WorkspaceTab.chat),
      ),
      _CommandAction(
        title: 'View Engineering Tasks & Kanban',
        category: 'NAVIGATION',
        icon: Icons.check_box_outlined,
        onSelect: () => workspace.setTab(WorkspaceTab.tasks),
      ),
      _CommandAction(
        title: 'Open Shared Documents & CRDT Specs',
        category: 'NAVIGATION',
        icon: Icons.description_outlined,
        onSelect: () => workspace.setTab(WorkspaceTab.docs),
      ),
      _CommandAction(
        title: 'Open Enterprise CRM Pipeline',
        category: 'NAVIGATION',
        icon: Icons.pie_chart_outline,
        onSelect: () => workspace.setTab(WorkspaceTab.crm),
      ),
      _CommandAction(
        title: 'Ask AI Copilot Contextual Assistant',
        category: 'AI ACTION',
        icon: Icons.auto_awesome,
        onSelect: () => workspace.toggleCopilotDrawer(),
      ),
    ];

    final filtered = actions
        .where(
          (a) =>
              a.title.toLowerCase().contains(_query.toLowerCase()) ||
              a.category.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 420),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: AppColors.borderStrong),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            // Search Input Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.borderDark)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: AppTypography.bodyLarge(
                        context,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        hintText:
                            'Type a command or search workspace... (Esc to exit)',
                        hintStyle: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: (val) => setState(() => _query = val),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: AppRadius.borderXs,
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Text('ESC', style: AppTypography.caption(context)),
                  ),
                ],
              ),
            ),

            // Command Options List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No matching actions found',
                        style: AppTypography.bodySmall(context),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return Material(
                          color: Colors.transparent,
                          child: ListTile(
                            dense: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.borderSm,
                            ),
                            leading: Icon(
                              item.icon,
                              size: 18,
                              color: AppColors.aiPurple,
                            ),
                            title: Text(
                              item.title,
                              style: AppTypography.body(
                                context,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            trailing: Text(
                              item.category,
                              style: AppTypography.caption(context),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              item.onSelect();
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommandAction {
  final String title;
  final String category;
  final IconData icon;
  final VoidCallback onSelect;

  const _CommandAction({
    required this.title,
    required this.category,
    required this.icon,
    required this.onSelect,
  });
}
