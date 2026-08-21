import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../design/components/entity_chip.dart';
import '../design/tokens/app_colors.dart';
import '../design/tokens/app_spacing.dart';
import '../design/tokens/app_typography.dart';
import '../features/agents/ai_chat_controller.dart';
import '../providers/workspace_provider.dart';

class AiCopilotDrawer extends StatefulWidget {
  final WorkspaceProvider provider;

  const AiCopilotDrawer({super.key, required this.provider});

  @override
  State<AiCopilotDrawer> createState() => _AiCopilotDrawerState();
}

class _AiCopilotDrawerState extends State<AiCopilotDrawer> {
  final TextEditingController _promptController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _sendPrompt(AiChatController chatController) {
    final text = _promptController.text.trim();
    if (text.isEmpty) return;

    chatController.sendPrompt(text);
    _promptController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final aiController = Provider.of<AiChatController>(context);

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
            child: const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  EntityChip(label: '#engineering', type: EntityType.chat),
                  SizedBox(width: AppSpacing.xs),
                  EntityChip(label: 'Sprint Task #482', type: EntityType.task),
                ],
              ),
            ),
          ),

          // Messages Stream List
          Expanded(
            child: aiController.messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.psychology_outlined,
                            size: 36,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Macro AI Cognition Ready',
                            style: AppTypography.title(context),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Submit a query to parse real workspace context across connected endpoints.',
                            style: AppTypography.caption(context),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: aiController.messages.length,
                    itemBuilder: (context, index) {
                      final msg = aiController.messages[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: msg.isUser
                              ? AppColors.aiPurple.withValues(alpha: 0.15)
                              : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: msg.isUser
                                ? AppColors.aiPurple.withValues(alpha: 0.3)
                                : AppColors.borderDark,
                          ),
                        ),
                        child: Text(
                          msg.text,
                          style: AppTypography.body(context),
                        ),
                      );
                    },
                  ),
          ),

          if (aiController.errorMessage != null)
            Container(
              margin: const EdgeInsets.all(AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.danger.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                aiController.errorMessage!,
                style: AppTypography.caption(context, color: AppColors.danger),
              ),
            ),

          if (aiController.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: LinearProgressIndicator(
                backgroundColor: AppColors.surfaceElevated,
                color: AppColors.aiPurple,
              ),
            ),

          // Prompt Input
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
                    style: AppTypography.body(context),
                    decoration: InputDecoration(
                      hintText: 'Ask AI Copilot...',
                      hintStyle: AppTypography.bodySmall(
                        context,
                        color: AppColors.textMuted,
                      ),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: AppColors.borderDark,
                        ),
                      ),
                    ),
                    onSubmitted: (_) => _sendPrompt(aiController),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  icon: const Icon(
                    Icons.send_rounded,
                    color: AppColors.aiPurple,
                  ),
                  onPressed: () => _sendPrompt(aiController),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
