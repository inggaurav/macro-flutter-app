enum EntityType {
  email,
  message,
  channel,
  task,
  document,
  contact,
  company,
  deal,
  agent,
  pullRequest,
  call,
  file,
}

class EntityRef {
  final EntityType type;
  final String id;
  final String title;
  final String? subtitle;

  const EntityRef({
    required this.type,
    required this.id,
    required this.title,
    this.subtitle,
  });

  String get tag => '@${type.name}:$id';
}

class EntityLink {
  final EntityRef source;
  final EntityRef target;
  final String
  relationshipType; // e.g. "generatedFrom", "linkedTo", "assignedTo"
  final DateTime createdAt;

  EntityLink({
    required this.source,
    required this.target,
    required this.relationshipType,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
