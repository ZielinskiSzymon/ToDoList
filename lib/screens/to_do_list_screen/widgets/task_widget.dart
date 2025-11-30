import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'task_card_content.dart';
import 'task_settings_dialog.dart';
import 'package:to_do_list/screens/to_do_list_screen/entities/task.dart';

class TaskWidget extends StatefulWidget {
  const TaskWidget({
    super.key,
    required this.title,
    required this.description,
    required this.deadline,
    required this.isCompited,
    required this.isArchived,
    this.listId,
    this.onRefresh, // Dodano pole onRefresh
  });

  final String title;
  final String? description;
  final String deadline;
  final bool isCompited;
  final bool isArchived;
  final int? listId;
  final VoidCallback? onRefresh; // Dodano typ VoidCallback

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  late bool _isMainListCompleted;
  late bool _isMainListArchived;
  List<Task>? subtasks;
  bool isSubtasksLoading = true;

  @override
  void initState() {
    super.initState();
    _isMainListCompleted = widget.isCompited;
    _isMainListArchived = widget.isArchived;
    fetchSubtasks();
  }

  @override
  void didUpdateWidget(covariant TaskWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isCompited != widget.isCompited) {
      _isMainListCompleted = widget.isCompited;
    }
    if (oldWidget.isArchived != widget.isArchived) {
      _isMainListArchived = widget.isArchived;
    }
  }

  Future<void> updateMainListCompletion(bool isCompleted, bool isArchived) async {
    if (widget.listId == null) return;

    try {
      final supabase = Supabase.instance.client;

      // Zmieniono 'isArchived' na 'is_archived'
      await supabase
          .from('to_do_lists')
          .update({'is_completed': isCompleted, 'is_archived': isArchived})
          .eq('list_id', widget.listId!);

      setState(() {
        _isMainListCompleted = isCompleted;
        _isMainListArchived = isArchived;
      });

    } catch (e) {
      debugPrint('Error updating main list completion: $e');
    }
  }

  Future<void> fetchSubtasks() async {
    if (widget.listId == null) {
      setState(() {
        subtasks = [];
        isSubtasksLoading = false;
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

      final responseData = response.map((task) => Task.fromJson(task)).toList();

      setState(() {
        subtasks = responseData;
        isSubtasksLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching subtasks: $e');
      setState(() {
        isSubtasksLoading = false;
        subtasks = [];
      });
    }
  }

  Future<void> updateTaskCompletion(Task task, bool isCompleted) async {
    if (task.taskId == null) return;

    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('tasks')
          .update({'is_completed': isCompleted} )
          .eq('task_id', task.taskId!);

      setState(() {
        final index = subtasks!.indexWhere((t) => t.taskId == task.taskId);
        if (index != -1) {
          subtasks![index] = Task(
            taskId: task.taskId,
            toDoListId: task.toDoListId,
            title: task.title,
            isCompleted: isCompleted,
          );
        }

        final allCompleted = subtasks!.every((t) => t.isCompleted);

        final newIsArchivedState = allCompleted;

        if (allCompleted && !_isMainListCompleted) {
          updateMainListCompletion(true, newIsArchivedState);
          if (widget.onRefresh != null) {
            widget.onRefresh!();
          }
        } else if (!allCompleted && _isMainListCompleted) {
          updateMainListCompletion(false, _isMainListArchived);
        }
      });
    } catch (e) {
      debugPrint('Error updating task completion: $e');
    }
  }

  Widget _buildSubtasksList() {
    return Column(
      children: [
        const Divider(height: 20, thickness: 1),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: subtasks!.length,
          itemBuilder: (context, index) {
            final subtask = subtasks![index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  subtask.isCompleted || _isMainListCompleted
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked,
                  color: subtask.isCompleted || _isMainListCompleted ? Theme.of(context).colorScheme.primary : Colors.grey,
                  size: 20,
                ),
                onPressed: () {
                  updateTaskCompletion(subtask, !subtask.isCompleted);
                },
              ),
              title: Text(
                subtask.title,
                style: TextStyle(
                  decoration: subtask.isCompleted || _isMainListCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: subtask.isCompleted || _isMainListCompleted? Colors.grey : null,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TaskCardContent(
                    title: widget.title,
                    description: widget.description,
                    deadline: widget.deadline,
                    isCompleted: _isMainListCompleted,
                  ),
                ),

                IconButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return TaskSettingsDialog(
                        title: widget.title,
                        listId: widget.listId,
                        fetchSubtask: (_) => fetchSubtasks(),
                      );
                    },
                  ),
                  icon: const Icon(Icons.settings),
                )
              ],
            ),

            if (isSubtasksLoading)
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (subtasks != null && subtasks!.isNotEmpty)
              _buildSubtasksList(),

            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final newIsCompleted = !_isMainListCompleted;
                    final newIsArchived = newIsCompleted;

                    await updateMainListCompletion(newIsCompleted, newIsArchived);

                    if (widget.onRefresh != null) {
                      widget.onRefresh!();
                    }
                  },
                  icon: Icon(
                    _isMainListCompleted ? Icons.undo : Icons.check,
                    size: 18,
                  ),
                  label: Text(
                    _isMainListCompleted
                        ? "Cofnij ukończenie listy"
                        : "Ukończ listę",
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}