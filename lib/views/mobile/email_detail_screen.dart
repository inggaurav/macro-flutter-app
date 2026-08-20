import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class EmailDetailScreen extends StatefulWidget {
  final EmailThread email;

  const EmailDetailScreen({super.key, required this.email});

  @override
  State<EmailDetailScreen> createState() => _EmailDetailScreenState();
}

class _EmailDetailScreenState extends State<EmailDetailScreen> {
  final TextEditingController _replyController = TextEditingController();
  bool _isDraftingAi = false;
  String? _aiDraftText;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _generateAiDraft() {
    setState(() {
      _isDraftingAi = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isDraftingAi = false;
          _aiDraftText =
              "Hi ${widget.email.senderName.split(' ')[0]},\n\nThanks for following up on ${widget.email.subject}. I've reviewed the updated CRM proposal terms with our team and we are aligned on moving forward.\n\nBest,\nAlex";
          _replyController.text = _aiDraftText!;
        });
      }
    });
  }

  void _sendReply() {
    if (_replyController.text.trim().isEmpty) return;
    final textSent = _replyController.text;
    _replyController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Reply sent to ${widget.email.senderName}: "${textSent.substring(0, textSent.length > 30 ? 30 : textSent.length)}..."',
        ),
        backgroundColor: AppTheme.accentEmerald,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.archive_outlined,
              color: AppTheme.textSecondary,
            ),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Thread archived')));
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: AppTheme.textSecondary,
            ),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Thread deleted')));
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.email.subject,
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
                          widget.email.senderName[0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.email.senderName,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '<${widget.email.senderEmail}>',
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        DateFormat(
                          'MMM d, h:mm a',
                        ).format(widget.email.timestamp),
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                  if (widget.email.linkedCompanyName != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentEmerald.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppTheme.accentEmerald.withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.link,
                            size: 14,
                            color: AppTheme.accentEmerald,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '@${widget.email.linkedCompanyName}',
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

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  Text(
                    widget.email.body,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Mobile AI Reply Assistant Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderDark),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.auto_awesome,
                              size: 16,
                              color: AppTheme.accentPurple,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Macro AI Reply Assistant',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _aiDraftText != null
                              ? 'AI Draft generated below! Edit or send.'
                              : 'Generate a response with updated CRM contract terms.',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryIndigo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: _isDraftingAi
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.flash_on, size: 16),
                            label: Text(
                              _isDraftingAi
                                  ? 'Synthesizing...'
                                  : 'Generate AI Draft',
                            ),
                            onPressed: _isDraftingAi ? null : _generateAiDraft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Interactive Reply Composer
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceDark,
                border: Border(top: BorderSide(color: AppTheme.borderDark)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.bgDark,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.borderDark),
                      ),
                      child: TextField(
                        controller: _replyController,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                        ),
                        maxLines: 3,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText:
                              'Reply to ${widget.email.senderName.split(' ')[0]}...',
                          hintStyle: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryIndigo,
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: _sendReply,
                    ),
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
