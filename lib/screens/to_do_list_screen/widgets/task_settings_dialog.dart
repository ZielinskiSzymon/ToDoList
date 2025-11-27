import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../entities/task.dart';

class TaskSettingsDialog extends StatefulWidget {
  final String title;
  final int? listId;
  final void Function(void) fetchSubtask;

  const TaskSettingsDialog({
    super.key,
    required this.title,
    required this.listId, required this.fetchSubtask,
  });

  @override
  State<TaskSettingsDialog> createState() => _TaskSettingsDialogState();
}

class _TaskSettingsDialogState extends State<TaskSettingsDialog> {
  @override
  void initState() {
    super.initState();
    fetchTask();
  }

  final TextEditingController _titleController = TextEditingController();
  List<Task>? tasks;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 2,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              if (tasks != null && tasks!.isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: tasks!.length,
                    itemBuilder: (context, index) {
                      final task = tasks![index];
                      return TaskListItem(
                        key: ValueKey(task.taskId),
                        task: task,
                        onUpdateTitle: updateTaskTitle,
                        onDelete: deleteTask,
                        fetchSubtask: () => widget.fetchSubtask(null),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                          hintText: "Enter new task title"
                      ),
                      onSubmitted: (_) => createNewTask(),
                    ),
                  ),
                  IconButton(
                    onPressed: createNewTask,
                    icon: const Icon(Icons.add),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }


  Future<void> fetchTask() async {
    if (widget.listId == null) {
      setState(() {
        tasks = [];
      });
      return;
    }

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from("tasks")
          .select()
          .eq('to_do_list_id', widget.listId!)
          .order('task_id', ascending: true)
      as List;

      final responseData = response
          .map((task) => Task.fromJson(task))
          .toList();

      setState(() {
        tasks = responseData;
      });

    } catch (err) {
      print('Error fetching tasks: $err');
      setState(() {
        tasks = [];
      });
    }
  }

  Future<void> createNewTask() async {
    if (_titleController.text.isEmpty || widget.listId == null) return;

    try {
      final supabase = Supabase.instance.client;

      final newTaskData = {
        'to_do_list_id': widget.listId,
        'title': _titleController.text,
        'is_completed': false,
      };

      await supabase.from('tasks').insert(newTaskData);

      _titleController.clear();

      await fetchTask();

    } catch (error) {
      print('Error adding task: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add task: $error')),
        );
      }
    }
  }

  Future<void> updateTaskTitle(int taskId, String newTitle) async {
    if (newTitle.trim().isEmpty) return;

    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('tasks')
          .update({'title': newTitle.trim()})
          .eq('task_id', taskId);

      setState(() {
        final index = tasks!.indexWhere((t) => t.taskId == taskId);
        if (index != -1) {
          tasks![index] = Task(
            taskId: tasks![index].taskId,
            toDoListId: tasks![index].toDoListId,
            title: newTitle.trim(),
            isCompleted: tasks![index].isCompleted,
          );
        }
      });

      print('Updated task $taskId title to: $newTitle');
    } catch (e) {
      print('Error updating task $taskId: $e');
    }
  }

  Future<void> deleteTask(int taskId) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('tasks')
          .delete()
          .eq('task_id', taskId);

      setState(() {
        tasks!.removeWhere((t) => t.taskId == taskId);
      });

      print('Deleted task $taskId');

    } catch (e) {
      print('Error deleting task $taskId: $e');
    }
  }
}
class TaskListItem extends StatefulWidget {
  final Task task;
  final Function(int taskId, String newTitle) onUpdateTitle;
  final Function(int taskId) onDelete;
  final VoidCallback fetchSubtask;

  const TaskListItem({
    super.key,
    required this.task,
    required this.onUpdateTitle,
    required this.onDelete,
    required this.fetchSubtask,
  });

  @override
  State<TaskListItem> createState() => _TaskListItemState();
}

class _TaskListItemState extends State<TaskListItem> {
  late TextEditingController _itemController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _itemController = TextEditingController(text: widget.task.title);
  }

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_itemController.text.trim() != widget.task.title) {
      widget.onUpdateTitle(widget.task.taskId!, _itemController.text);
    }


    setState(() {
      _isEditing = false;
      widget.fetchSubtask();

    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: TextFormField(
        controller: _itemController,
        decoration: InputDecoration(
          border: _isEditing ? const UnderlineInputBorder() : InputBorder.none,
        ),
        onTap: () {
          setState(() {
            _isEditing = true;
          });
        },
        onFieldSubmitted: (_) => _handleSave(),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save_outlined, color: Colors.blue),
              onPressed: _handleSave,
            ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              if (widget.task.taskId != null) {
                widget.onDelete(widget.task.taskId!);
              }
            },
          ),
        ],
      ),
    );
  }
}