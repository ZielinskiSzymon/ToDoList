import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:to_do_list/screens/to_do_list_screen/entities/to_do_list_entity.dart';
import 'package:to_do_list/widgets/AppButton.dart';
import 'package:to_do_list/widgets/form_field.dart';

class ToDoListScreen extends StatefulWidget {
  const ToDoListScreen({super.key});

  @override
  State<ToDoListScreen> createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text("Twoje Listy Zadań"),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () => showDialog(
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (context, setStateDialog) {
                  return Dialog(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                  "Nowa lista zadań",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center),
                              const SizedBox(height: 20),
                              FormFieldWidget(
                                controller: _titleController,
                                isPassword: false,
                                icon: Icons.edit_note_sharp,
                                hintText: "Tytuł",
                                numbersOnly: false,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "To pole nie może być puste";
                                  }
                                  if (value.length < 3) {
                                    return "Tytuł jest za krótki! (min. 3 znaki)";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 15),
                              FormFieldWidget(
                                controller: _descriptionController,
                                isPassword: false,
                                icon: Icons.description,
                                hintText: "Opis (opcjonalne)",
                                numbersOnly: false,
                              ),
                              const SizedBox(height: 15),
                              FormFieldWidget(
                                controller: _deadlineController,
                                isPassword: false,
                                icon: Icons.calendar_today,
                                hintText: "Liczba dni na realizację",
                                numbersOnly: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "To pole nie może być puste";
                                  }
                                  final days = int.tryParse(value);
                                  if (days == null || days < 0) {
                                    return "Data musi być liczbą dodatnią";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 25),
                              AppButton(
                                title: "Dodaj listę",
                                isLoading: isLoading,
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    setStateDialog(() {
                                      isLoading = true;
                                    });

                                    try {
                                      await createNewToDoList(
                                        title: _titleController.text,
                                        description: _descriptionController.text,
                                        duration: int.parse(_deadlineController.text),
                                      );

                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                        _titleController.clear();
                                        _descriptionController.clear();
                                        _deadlineController.clear();
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Błąd: $e')),
                                        );
                                      }
                                    } finally {
                                      setStateDialog(() {
                                        isLoading = false;
                                      });
                                    }
                                  }
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          icon: const Icon(Icons.add),
        ),
        const SizedBox(width: 20),
      ],
    ),
    body: const SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Wyświetlanie list zadań")
            ],
          ),
        )),
  );

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

    try {
      final response = await supabase
          .from('to_do_lists')
          .insert(listJson)
          .select();

      print('Lista zadań utworzona pomyślnie: ${response.first['title']}');
    } catch (err) {
      print('Błąd podczas dodawania: $err');
    }
  }
}
