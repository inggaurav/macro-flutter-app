import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/workspace_provider.dart';
import '../theme/app_theme.dart';
import 'mobile/email_detail_screen.dart';

class InboxView extends StatelessWidget {
  final WorkspaceProvider provider;

  const InboxView({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    final selectedEmail = provider.emails.firstWhere(
      (e) => e.id == provider.selectedEmailId,
      orElse: () => provider.emails.first,
    );

    final emailListWidget = Container(
      width: isMobile ? double.infinity : 340,
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
                Row(
                  children: [
                    const Text(
                      'Inbox',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryIndigo.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${provider.emails.where((e) => e.isUnread).length} unread',
                        style: const TextStyle(
                          color: AppTheme.primaryIndigo,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.edit_square, size: 20, color: AppTheme.primaryIndigo),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Email Search
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Search email threads...',
                hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                prefixIcon: const Icon(Icons.search, size: 16, color: AppTheme.textMuted),
                fillColor: AppTheme.surfaceDark,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.borderDark),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.borderDark),
                ),
              ),
            ),
          ),

          // Threads List
          Expanded(
            child: ListView.separated(
              itemCount: provider.emails.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final email = provider.emails[index];
                final isSelected = !isMobile && email.id == selectedEmail.id;

                return ListTile(
                  selected: isSelected,
                  selectedTileColor: AppTheme.primaryIndigo.withOpacity(0.15),
                  onTap: () {
                    provider.selectEmail(email.id);
                    if (isMobile) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EmailDetailScreen(email: email),
                        ),
                      );
                    }
                  },
                  leading: CircleAvatar(
                    backgroundColor: isSelected
                        ? AppTheme.primaryIndigo
                        : AppTheme.surfaceLightDark,
                    child: Text(
                      email.senderName[0],
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          email.senderName,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: email.isUnread ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        DateFormat('h:mm a').format(email.timestamp),
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(
                        email.subject,
                        style: TextStyle(
                          color: email.isUnread ? AppTheme.textPrimary : AppTheme.textSecondary,
                          fontWeight: email.isUnread ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email.preview,
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        children: email.tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceLightDark,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 9),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
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
        body: emailListWidget,
      );
    }

    // Desktop Split-Pane View
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Row(
        children: [
          emailListWidget,
          Expanded(
            child: Column(
              children: [
                // Mail Detail Top Header Toolbar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppTheme.borderDark)),
                  ),
                  child: Row(
                    children: [
                      IconButton(icon: const Icon(Icons.archive_outlined, size: 20), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.delete_outline, size: 20), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.mark_email_unread_outlined, size: 20), onPressed: () {}),
                      const Spacer(),
                      if (selectedEmail.linkedCompanyName != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accentEmerald.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.accentEmerald.withOpacity(0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.link, size: 14, color: AppTheme.accentEmerald),
                              const SizedBox(width: 4),
                              Text(
                                '@${selectedEmail.linkedCompanyName}',
                                style: const TextStyle(
                                  color: AppTheme.accentEmerald,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Mail Content Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedEmail.subject,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppTheme.primaryIndigo,
                              child: Text(
                                selectedEmail.senderName[0],
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedEmail.senderName,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '<${selectedEmail.senderEmail}> to me',
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              DateFormat('MMM d, yyyy • h:mm a').format(selectedEmail.timestamp),
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 20),

                        Text(
                          selectedEmail.body,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 36),

                        // AI Draft Assistant Banner
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceDark,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.borderDark),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.auto_awesome, size: 18, color: AppTheme.accentPurple),
                                  const SizedBox(width: 8),
                                  Text(
                                    'AI Reply Assistant (${provider.activeAiModel})',
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Macro AI can draft an email response incorporating your recent CRM deals, docs, and calendar availability.',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryIndigo,
                                      foregroundColor: Colors.white,
                                    ),
                                    icon: const Icon(Icons.flash_on, size: 16),
                                    label: const Text('Generate Order Form Reply'),
                                    onPressed: () {},
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.textPrimary,
                                      side: const BorderSide(color: AppTheme.borderDark),
                                    ),
                                    onPressed: () {},
                                    child: const Text('Schedule Meeting Link'),
                                  ),
                                ],
                              ),
                            ],
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
