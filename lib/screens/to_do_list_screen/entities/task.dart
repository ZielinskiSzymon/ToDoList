class Task {
  final int? taskId;
  final int toDoListId;
  final String title;
  final bool isCompleted;

  Task({
    this.taskId,
    required this.toDoListId,
    required this.title,
    this.isCompleted = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskId: json['task_id'] as int?,
      toDoListId: json['to_do_list_id'] as int,
      title: json['title'] as String,
      isCompleted: json['is_completed'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'to_do_list_id': toDoListId,
      'title': title,
      'is_completed': isCompleted,
    };
  }
}