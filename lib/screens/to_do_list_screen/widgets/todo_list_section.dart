import 'package:flutter/material.dart';
import 'package:to_do_list/screens/to_do_list_screen/entities/todo_entity.dart';
import 'package:to_do_list/screens/to_do_list_screen/widgets/task_widget.dart';

class ToDoListListSection extends StatelessWidget {
  const ToDoListListSection({
    super.key,
    required this.tasksArray,
    this.onRefresh,
  });

  final List<ToDoListEntity> tasksArray;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final List<ToDoListEntity> visibleTasks = tasksArray
        .where((task) => !task.isCompleted && !task.isArchived)
        .toList();

    if (visibleTasks.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            "Brak zadań do wykonania!",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: visibleTasks.length,
        itemBuilder: (context, index) {
          final task = visibleTasks[index];
          final deadlineString = task.deadline != null
              ? "${task.deadline!.day}.${task.deadline!.month}.${task.deadline!.year}"
              : "Brak terminu";

          return TaskWidget(
            title: task.title,
            description: task.description,
            deadline: deadlineString,
            isCompited: task.isCompleted,
            isArchived: task.isArchived,
            listId: task.listId,
            onRefresh: onRefresh,
          );
        },
      ),
    );
  }
}