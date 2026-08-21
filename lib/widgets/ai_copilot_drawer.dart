import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../design/components/entity_chip.dart';
import '../design/tokens/app_colors.dart';
import '../design/tokens/app_spacing.dart';
import '../design/tokens/app_typography.dart';
import '../providers/workspace_provider.dart';

class AiCopilotDrawer extends StatefulWidget {
  final WorkspaceProvider provider;

  const AiCopilotDrawer({super.key, required this.provider});

  @override
  State<AiCopilotDrawer> createState() => _AiCopilotDrawerState();
}

class _AiCopilotDrawerState extends State<AiCopilotDrawer> {
  final TextEditingController _promptController = TextEditingController();
  final List<_CopilotMessage> _messages = [
    _CopilotMessage(
      text:
          'Hello Alex! I am your Macro AI Copilot. I have context on your emails, tasks, and CRDT specs.',
      isUser: false,
    ),
  ];

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _sendPrompt() {
    final text = _promptController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_CopilotMessage(text: text, isUser: true));
      _messages.add(
        _CopilotMessage(
          text:
              'I parsed your request against #engineering channels and tasks. Target WebSocket latency is <45ms.',
          isUser: false,
        ),
      );
    });
    _promptController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(left: BorderSide(color: AppColors.borderDark)),
      ),
      child: Column(
        children: [
          // Copilot Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.borderDark)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: AppColors.aiPurple,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'AI Copilot Assistant',
                      style: AppTypography.title(context),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                  onPressed: () => widget.provider.toggleCopilotDrawer(),
                ),
              ],
            ),
          ),

          // Active Context Chips
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            color: AppColors.surfaceElevated,
            child: Row(
              children: [
                Text('Active Context: ', style: AppTypography.caption(context)),
                const EntityChip(
                  label: 'Workspace #main',
                  type: EntityType.agent,
                ),
              ],
            ),
          ),

          // Messages Stream
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: msg.isUser
                          ? AppColors.brandPrimary(
                              Provider.of<AppConfig>(context),
                            )
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg.text,
                      style: AppTypography.body(context, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),

          // Prompt Input Bar
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.borderDark)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promptController,
                    style: AppTypography.body(
                      context,
                      color: AppColors.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Ask AI Copilot...',
                      hintStyle: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendPrompt(),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: AppColors.aiPurple,
                    size: 18,
                  ),
                  onPressed: _sendPrompt,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CopilotMessage {
  final String text;
  final bool isUser;

  const _CopilotMessage({required this.text, required this.isUser});
}
