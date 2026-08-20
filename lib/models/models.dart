import 'package:flutter/material.dart';

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
}

class EmailThread {
  final String id;
  final String subject;
  final String senderName;
  final String senderEmail;
  final String preview;
  final String body;
  final DateTime timestamp;
  final bool isUnread;
  final bool isStarred;
  final List<String> tags;
  final String? linkedCompanyName;

  EmailThread({
    required this.id,
    required this.subject,
    required this.senderName,
    required this.senderEmail,
    required this.preview,
    required this.body,
    required this.timestamp,
    this.isUnread = false,
    this.isStarred = false,
    required this.tags,
    this.linkedCompanyName,
  });
}

class ChatMessage {
  final String id;
  final String channelId;
  final String senderName;
  final String senderAvatar;
  final String text;
  final DateTime timestamp;
  final bool isAgent;
  final List<String> mentions; // e.g. ["@Acme Corp", "@Task-402"]
  final String? codeSnippet;

  ChatMessage({
    required this.id,
    required this.channelId,
    required this.senderName,
    required this.senderAvatar,
    required this.text,
    required this.timestamp,
    this.isAgent = false,
    this.mentions = const [],
    this.codeSnippet,
  });
}

class ChatChannel {
  final String id;
  final String name;
  final String description;
  final bool isPrivate;
  final int unreadCount;
  final DateTime lastActivity;

  ChatChannel({
    required this.id,
    required this.name,
    required this.description,
    this.isPrivate = false,
    this.unreadCount = 0,
    required this.lastActivity,
  });
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
}

class AiMemoryItem {
  final String id;
  final String category; // 'team_context', 'sales_insight', 'tech_stack'
  final String title;
  final String summary;
  final String source; // 'Slack #engineering', 'Email thread', 'CRDT Document'
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
}
