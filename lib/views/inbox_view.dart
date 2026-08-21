import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../features/inbox/controllers/inbox_controller.dart';
import '../providers/workspace_provider.dart';
import '../theme/app_theme.dart';
import 'mobile/email_detail_screen.dart';

class InboxView extends StatefulWidget {
  final WorkspaceProvider provider;

  const InboxView({super.key, required this.provider});

  @override
  State<InboxView> createState() => _InboxViewState();
}

class _InboxViewState extends State<InboxView> {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final inboxController = Provider.of<InboxController>(context);

    final emails = inboxController.emails;
    final selectedEmail = inboxController.selectedEmail;

    final emailListWidget = Container(
      width: isMobile ? double.infinity : 340,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(right: BorderSide(color: AppTheme.borderDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.borderDark)),
            ),
            child: const Text(
              'Inbox & Communication',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: inboxController.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primaryIndigo,
                    ),
                  )
                : ListView.builder(
                    itemCount: emails.length,
                    itemBuilder: (context, index) {
                      final email = emails[index];
                      final isSelected =
                          !isMobile && email.id == selectedEmail?.id;

                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          selected: isSelected,
                          selectedTileColor: AppTheme.primaryIndigo.withOpacity(
                            0.15,
                          ),
                          onTap: () {
                            inboxController.selectEmail(email.id);
                            if (isMobile) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EmailDetailScreen(email: email),
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
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.textPrimary,
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
                                    fontWeight: email.isUnread
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                DateFormat('h:mm a').format(email.timestamp),
                                style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 10,
                                ),
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
                                  color: email.isUnread
                                      ? AppTheme.textPrimary
                                      : AppTheme.textSecondary,
                                  fontWeight: email.isUnread
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email.preview,
                                style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 11,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );

    if (isMobile) {
      return Scaffold(backgroundColor: AppTheme.bgDark, body: emailListWidget);
    }

    // Desktop Split Screen View
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Row(
        children: [
          emailListWidget,
          Expanded(
            child: selectedEmail == null
                ? const Center(
                    child: Text(
                      'Select an email thread to read',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  )
                : Container(
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
                              backgroundColor: AppTheme.primaryIndigo,
                              child: Text(
                                selectedEmail.senderName[0],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
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
                                  selectedEmail.senderEmail,
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              DateFormat(
                                'MMM d, h:mm a',
                              ).format(selectedEmail.timestamp),
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedEmail.body,
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 14,
                                    height: 1.6,
                                  ),
                                ),
                                if (inboxController.generatedReplyDraft !=
                                    null) ...[
                                  const SizedBox(height: 24),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceDark,
                                      border: Border.all(
                                        color: AppTheme.accentPurple
                                            .withOpacity(0.3),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(
                                              Icons.auto_awesome,
                                              color: AppTheme.accentPurple,
                                              size: 16,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              'AI Copilot Reply Draft',
                                              style: TextStyle(
                                                color: AppTheme.accentPurple,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          inboxController.generatedReplyDraft!,
                                          style: const TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontSize: 13,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accentPurple,
                              ),
                              icon: inboxController.isGeneratingAiReply
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.auto_awesome, size: 16),
                              label: const Text('Generate AI Reply'),
                              onPressed: inboxController.isGeneratingAiReply
                                  ? null
                                  : () => inboxController.generateAiReply(
                                      selectedEmail.id,
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
