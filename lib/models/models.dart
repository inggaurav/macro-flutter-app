import '../features/inbox/domain/email_thread.dart';
import '../features/chat/domain/chat_channel.dart';
import '../features/chat/domain/chat_message.dart';

export '../features/inbox/domain/email_thread.dart';
export '../features/chat/domain/chat_channel.dart';
export '../features/chat/domain/chat_message.dart';

enum TaskStatus { todo, inProgress, inReview, done }

enum TaskPriority { low, medium, high, urgent }

enum DealStage { lead, proposal, negotiation, closedWon, closedLost }

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String role;
  final bool isOnline;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.role,
    this.isOnline = true,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? 'u_unknown',
      name: json['name']?.toString() ?? 'User',
      email: json['email']?.toString() ?? 'user@macro.com',
      avatarUrl: json['avatar_url']?.toString() ?? '',
      role: json['role']?.toString() ?? 'Member',
      isOnline: json['is_online'] == true,
    );
  }
}

class DocumentItem {
  final String id;
  final String title;
  final String content;
  final String authorName;
  final DateTime lastModified;
  final List<String> tags;
  final int versionCount;
  final bool isPinned;

  DocumentItem({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.lastModified,
    required this.tags,
    this.versionCount = 1,
    this.isPinned = false,
  });

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      id: json['id']?.toString() ?? 'd_unknown',
      title: json['title']?.toString() ?? 'Untitled Document',
      content: json['content']?.toString() ?? '',
      authorName: json['author_name']?.toString() ?? 'Workspace Member',
      lastModified:
          DateTime.tryParse(json['last_modified']?.toString() ?? '') ??
          DateTime.now(),
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      versionCount: (json['version_count'] as num?)?.toInt() ?? 1,
      isPinned: json['is_pinned'] == true,
    );
  }
}

class TaskItem {
  final String id;
  final String title;
  final String description;
  TaskStatus status;
  final TaskPriority priority;
  final String assigneeName;
  final String assigneeAvatar;
  final DateTime dueDate;
  final List<String> tags;

  TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.assigneeName,
    required this.assigneeAvatar,
    required this.dueDate,
    required this.tags,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id']?.toString() ?? 't_unknown',
      title: json['title']?.toString() ?? 'Untitled Task',
      description: json['description']?.toString() ?? '',
      status: TaskStatus.values.firstWhere(
        (s) => s.name == json['status']?.toString(),
        orElse: () => TaskStatus.todo,
      ),
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == json['priority']?.toString(),
        orElse: () => TaskPriority.medium,
      ),
      assigneeName: json['assignee_name']?.toString() ?? 'Unassigned',
      assigneeAvatar: json['assignee_avatar']?.toString() ?? '',
      dueDate:
          DateTime.tryParse(json['due_date']?.toString() ?? '') ??
          DateTime.now(),
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class CrmDeal {
  final String id;
  final String title;
  final String companyName;
  final double value;
  DealStage stage;
  final String contactName;
  final String contactEmail;
  final String lastInteraction;
  final List<String> tags;

  CrmDeal({
    required this.id,
    required this.title,
    required this.companyName,
    required this.value,
    required this.stage,
    required this.contactName,
    required this.contactEmail,
    required this.lastInteraction,
    required this.tags,
  });

  factory CrmDeal.fromJson(Map<String, dynamic> json) {
    return CrmDeal(
      id: json['id']?.toString() ?? 'deal_unknown',
      title: json['title']?.toString() ?? 'Untitled Deal',
      companyName: json['company_name']?.toString() ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      stage: DealStage.values.firstWhere(
        (s) => s.name == json['stage']?.toString(),
        orElse: () => DealStage.lead,
      ),
      contactName: json['contact_name']?.toString() ?? '',
      contactEmail: json['contact_email']?.toString() ?? '',
      lastInteraction: json['last_interaction']?.toString() ?? '',
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class AiMemoryItem {
  final String id;
  final String category;
  final String title;
  final String summary;
  final String source;
  final double confidence;
  final DateTime updatedAt;

  AiMemoryItem({
    required this.id,
    required this.category,
    required this.title,
    required this.summary,
    required this.source,
    required this.confidence,
    required this.updatedAt,
  });

  factory AiMemoryItem.fromJson(Map<String, dynamic> json) {
    return AiMemoryItem(
      id: json['id']?.toString() ?? 'mem_unknown',
      category: json['category']?.toString() ?? 'general',
      title: json['title']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class CallSession {
  final String id;
  final String title;
  final bool isLive;
  final int durationMinutes;
  final List<String> participantAvatars;
  final String liveTranscript;
  final String aiSummary;

  CallSession({
    required this.id,
    required this.title,
    required this.isLive,
    required this.durationMinutes,
    required this.participantAvatars,
    required this.liveTranscript,
    required this.aiSummary,
  });

  factory CallSession.fromJson(Map<String, dynamic> json) {
    return CallSession(
      id: json['id']?.toString() ?? 'call_unknown',
      title: json['title']?.toString() ?? 'Call Record',
      isLive: json['is_live'] == true,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
      participantAvatars:
          (json['participant_avatars'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      liveTranscript: json['live_transcript']?.toString() ?? '',
      aiSummary: json['ai_summary']?.toString() ?? '',
    );
  }
}
