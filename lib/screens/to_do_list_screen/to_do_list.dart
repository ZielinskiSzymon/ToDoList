import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:to_do_list/screens/to_do_list_screen/entities/todo_entity.dart';
import 'package:to_do_list/screens/to_do_list_screen/widgets/todo_appbar.dart';
import 'package:to_do_list/screens/to_do_list_screen/widgets/todo_list_section.dart';

class ToDoListScreen extends StatefulWidget {
  const ToDoListScreen({super.key});

  @override
  State<ToDoListScreen> createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  List<ToDoListEntity>? tasksArray;
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    fetchTasks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: ToDoListAppbar(onListCreated: fetchTasks),
    body: SafeArea(
      child: Center(
        child: TaskContent(
          isLoading: isLoading,
          isError: isError,
          tasksArray: tasksArray,
          fetchTasks: fetchTasks,
        ),
      ),
    ),
  );

  Future<void> fetchTasks() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      setState(() {
        tasksArray = [];
        isLoading = false;
        isError = false;
      });
      return;
    }

    try {
      final response = await supabase
          .from("to_do_lists")
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
      as List;

      final responseData = response
          .map((list) => ToDoListEntity.fromJson(list))
          .toList();

      setState(() {
        tasksArray = responseData;
        isLoading = false;
      });
    }catch(err){
      setState(() {
        isError = true;
      });
      print(err);
    }
  }
}

class TaskContent extends StatelessWidget {
  const TaskContent({
    super.key,
    required this.isLoading,
    required this.isError,
    this.tasksArray,
    required this.fetchTasks,
  });

  final bool isLoading;
  final bool isError;
  final List<ToDoListEntity>? tasksArray;
  final VoidCallback fetchTasks;

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const CircularProgressIndicator();
    }

    if (isError) {
      return Text("Wystąpił błąd podczas ładowania list. Spróbuj ponownie.");
    }

    if (tasksArray == null || tasksArray!.isEmpty) {
      return Expanded(
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Brak list zadań",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: fetchTasks,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Odśwież"),
                ),
              ],
            )
        ),
      );
    }

    return ToDoListListSection(tasksArray: tasksArray!);
  }
}