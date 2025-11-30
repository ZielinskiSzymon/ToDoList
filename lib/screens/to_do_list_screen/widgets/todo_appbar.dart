import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../widgets/AppButton.dart';
import '../../../widgets/form_field.dart';
import '../entities/todo_entity.dart';

class ToDoListAppbar extends StatefulWidget implements PreferredSizeWidget {
  const ToDoListAppbar({super.key, required this.onListCreated});

  final VoidCallback onListCreated;
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<ToDoListAppbar> createState() => _ToDoListAppbarState();
}

class _ToDoListAppbarState extends State<ToDoListAppbar> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: Text(
        "Twoje Listy Zadań",
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            onPressed: () => _showAddListDialog(context),
            icon: const Icon(Icons.add_task_rounded),
          ),
        ),
      ],
    );
  }

  void _showAddListDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 10,
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Nowa lista zadań",
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Wypełnij poniższe dane, aby utworzyć nową listę.",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          FormFieldWidget(
                            controller: _titleController,
                            isPassword: false,
                            icon: Icons.edit_note_sharp,
                            hintText: "Tytuł listy",
                            numbersOnly: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "To pole jest wymagane";
                              }
                              if (value.length < 3) {
                                return "Minimum 3 znaki";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          FormFieldWidget(
                            controller: _descriptionController,
                            isPassword: false,
                            icon: Icons.description_outlined,
                            hintText: "Opis (opcjonalne)",
                            numbersOnly: false,
                          ),
                          const SizedBox(height: 16),
                          FormFieldWidget(
                            controller: _deadlineController,
                            isPassword: false,
                            icon: Icons.timer_outlined,
                            hintText: "Dni na realizację",
                            numbersOnly: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "To pole jest wymagane";
                              }
                              final days = int.tryParse(value);
                              if (days == null || days < 1) {
                                return "Minimum 1 dzień";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      )
                                  ),
                                  child: const Text("Anuluj"),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppButton(
                                  title: "Utwórz",
                                  isLoading: isLoading,
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      setStateDialog(() => isLoading = true);
                                      try {
                                        await createNewToDoList(
                                          title: _titleController.text,
                                          description: _descriptionController.text,
                                          duration: int.parse(_deadlineController.text),
                                        );

                                        if (context.mounted) {
                                          Navigator.of(context).pop();
                                          _clearControllers();
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Błąd podczas tworzenia listy: $e'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      } finally {
                                        setStateDialog(() => isLoading = false);
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _clearControllers() {
    _titleController.clear();
    _descriptionController.clear();
    _deadlineController.clear();
  }

  Future<void> createNewToDoList({
    required String title,
    required String description,
    required int duration,
  }) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('Użytkownik nie jest zalogowany.');
    }

    final newToDoList = ToDoListEntity(
      title: title,
      description: description,
      deadline: DateTime.now().add(Duration(days: duration)),
      createdAt: DateTime.now(),
    );

    final listJson = newToDoList.toJson();
    listJson['user_id'] = userId;

      final response = await supabase
          .from('to_do_lists')
          .insert(listJson)
          .eq("is_completed", "true")
          .select();

      widget.onListCreated();

      print('Lista zadań utworzona pomyślnie: ${response.first['title']}');
  }
}
