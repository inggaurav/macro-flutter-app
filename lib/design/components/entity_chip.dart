import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';

enum EntityType { email, chat, task, document, deal, agent, pr, call }

class EntityChip extends StatelessWidget {
  final String label;
  final EntityType type;
  final VoidCallback? onTap;

  const EntityChip({
    super.key,
    required this.label,
    required this.type,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (type) {
      case EntityType.email:
        icon = Icons.mail_outline;
        color = AppColors.info;
        break;
      case EntityType.chat:
        icon = Icons.chat_bubble_outline;
        color = AppColors.aiPurple;
        break;
      case EntityType.task:
        icon = Icons.check_circle_outline;
        color = AppColors.warning;
        break;
      case EntityType.document:
        icon = Icons.article_outlined;
        color = AppColors.aiCyan;
        break;
      case EntityType.deal:
        icon = Icons.attach_money;
        color = AppColors.success;
        break;
      case EntityType.agent:
        icon = Icons.auto_awesome;
        color = AppColors.aiPurple;
        break;
      case EntityType.pr:
        icon = Icons.alt_route;
        color = Colors.indigoAccent;
        break;
      case EntityType.call:
        icon = Icons.call_outlined;
        color = Colors.pinkAccent;
        break;
    }

    final chipWidget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.borderSm,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.label(
              context,
              color: color,
            ).copyWith(fontSize: 10),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderSm,
        child: chipWidget,
      );
    }

    return chipWidget;
  }
}
