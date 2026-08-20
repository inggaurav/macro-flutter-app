import 'package:flutter/material.dart';
import '../providers/workspace_provider.dart';
import '../theme/app_theme.dart';

class AiCopilotDrawer extends StatefulWidget {
  final WorkspaceProvider provider;

  const AiCopilotDrawer({super.key, required this.provider});

  @override
  State<AiCopilotDrawer> createState() => _AiCopilotDrawerState();
}

class _AiCopilotDrawerState extends State<AiCopilotDrawer> {
  final TextEditingController _promptController = TextEditingController();
  final List<Map<String, String>> _copilotChat = [
    {
      'role': 'assistant',
      'text':
          'Hello Alex! I have synthesized today\'s team memory from Email, Chat, Docs, and CRM. How can I assist your workflow?',
    },
  ];

  void _sendPrompt(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _copilotChat.add({'role': 'user', 'text': text});
      _promptController.clear();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _copilotChat.add({
            'role': 'assistant',
            'text':
                '🤖 [Model: ${widget.provider.activeAiModel}]\nI checked @Acme Corp (\$120k ARR) and linked @Doc/PRD. Action items updated across Workspace memory.',
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth < 768 ? screenWidth * 0.92 : 340.0;

    return Container(
      width: drawerWidth,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(left: BorderSide(color: AppTheme.borderDark)),
      ),
      child: Column(
        children: [
          // Copilot Drawer Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.borderDark)),
            ),
            child: Row(
              children: [
                const Icon(Icons.psychology, color: AppTheme.primaryIndigo),
                const SizedBox(width: 8),
                const Text(
                  'Macro AI Copilot',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => widget.provider.toggleCopilotDrawer(),
                ),
              ],
            ),
          ),

          // Active Shared Memory Insight Box
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryIndigo.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.primaryIndigo.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: AppTheme.accentPurple,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Team Shared Memory Context',
                      style: TextStyle(
                        color: AppTheme.accentPurple,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Synthesized from 3 emails, 12 chat messages, and 2 CRM deals today. Confidence: 99%.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),

          // Conversation Stream
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _copilotChat.length,
              itemBuilder: (context, index) {
                final msg = _copilotChat[index];
                final isUser = msg['role'] == 'user';

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: isUser
                          ? AppTheme.primaryIndigo
                          : AppTheme.surfaceLightDark,
                      borderRadius: BorderRadius.circular(10),
                      border: isUser
                          ? null
                          : Border.all(color: AppTheme.borderDark),
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(
                        color: isUser ? Colors.white : AppTheme.textPrimary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Quick Action Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                _buildQuickChip('Summarize @Acme Corp'),
                _buildQuickChip('Draft Reply to Sarah'),
                _buildQuickChip('Create Task from Chat'),
              ],
            ),
          ),

          // Prompt Input Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.borderDark)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promptController,
                    onSubmitted: _sendPrompt,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 12,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Ask AI Copilot or type @...',
                      hintStyle: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.send,
                    size: 18,
                    color: AppTheme.primaryIndigo,
                  ),
                  onPressed: () => _sendPrompt(_promptController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        backgroundColor: AppTheme.surfaceLightDark,
        side: const BorderSide(color: AppTheme.borderDark),
        label: Text(
          text,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
        ),
        onPressed: () => _sendPrompt(text),
      ),
    );
  }
}
