class ToDoListEntity {
  final int? listId;
  final String title;
  final String? description;
  final DateTime? deadline;
  final bool isCompleted;
  final DateTime createdAt;
  final bool isArchived;

  ToDoListEntity({
    this.listId,
    required this.title,
    this.description,
    this.deadline,
    this.isCompleted = false,
    required this.createdAt,
    this.isArchived = false,
  });

  factory ToDoListEntity.fromJson(Map<String, dynamic> json) {
    return ToDoListEntity(
      listId: json['list_id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String?,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
      isCompleted: json['is_completed'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      isArchived: json['is_archived'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'deadline': deadline?.toIso8601String(),
      'is_completed': isCompleted,
      'is_archived': isArchived,
    };
  }
}