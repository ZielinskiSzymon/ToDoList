import 'package:flutter/material.dart';
import 'package:to_do_list/screens/to_do_list_screen/entities/todo_entity.dart';
import 'package:to_do_list/screens/to_do_list_screen/widgets/task_widget.dart';

class ToDoListListSection extends StatelessWidget {
  const ToDoListListSection({super.key, required this.tasksArray});

  final List<ToDoListEntity> tasksArray;
  @override
  Widget build(BuildContext context) => Expanded(
    child: ListView.builder(
      itemCount: tasksArray.length,
      itemBuilder: (context, index) {
        final task = tasksArray[index];
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
        );
      },
    ),
  );
}
