import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:to_do_list/screens/login_screen/login_screen.dart';
import 'package:to_do_list/screens/main_screen/main_screen.dart';
import '../../widgets/AppButton.dart';
import '../../widgets/form_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordRepeatController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("ToDo List",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text("Zarejestruj sie abu zacząć zapisywać i dzielić sie swoimi zadaniami.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),

                  ),
                  const SizedBox(height: 20),
                  FormFieldWidget(
                    controller: _nameController,
                    isPassword: false,
                    icon: Icons.person,
                    hintText: "Imię",
                    validator: (value) {
                      if(value == null || value.isEmpty){
                        return "To pole nie może być puste";
                      }
                      if(value.length < 3){
                        return "Imię jest za krótkie! (min. 3 znaki)";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  FormFieldWidget(
                    controller: _emailController,
                    isPassword: false,
                    icon: Icons.email,
                    hintText: "Email",
                    validator: (value) => emailValidator(value, "Email"),
                  ),
                  const SizedBox(height: 20),
                  FormFieldWidget(
                    controller: _passwordController,
                    isPassword: true,
                    icon: Icons.lock,
                    hintText: "Hasło",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "To pole nie może być puste!";
                      }
                      if (value.length < 6) {
                        return "Hasło jest za krótkie! (min. 6 znaków)";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  FormFieldWidget(
                    controller: _passwordRepeatController,
                    isPassword: true,
                    icon: Icons.lock,
                    hintText: "Powtórz hasło",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "To pole nie może być puste!";
                      }
                      if (value != _passwordController.text) {
                        return "Hasła nie są takie same!";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  AppButton(title: "Zarejestruj się",onPressed:() {
                    if(_formKey.currentState!.validate()) {
                      registerUser();
                    }
                  },isLoading: isLoading),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen())
                      ),
                    },
                    child: Text("Masz już konto? Zaloguj się!"),
                  )
                ],
              ),
            ),
          ),
      ),
    ),
  );

  Future<void> registerUser() async {
    try {
      setState(() {
        isLoading = true;
      });

      final supabaseInstance = Supabase.instance.client;
      final String name = _nameController.text.trim();
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      await supabaseInstance.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': name,
        },
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
            (Route<dynamic> route) => false,
      );
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Błąd rejestracji: $err")),
      );
    }
  }

  String? emailValidator(String? value, String hintText) {
    if (value == null || value.isEmpty) {
      return "Pole $hintText nie może być puste!";
    }
    final emailRegex = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!emailRegex.hasMatch(value)) {
      return "Podaj prawidłowy format maila.";
    }
    return null;
  }
}
