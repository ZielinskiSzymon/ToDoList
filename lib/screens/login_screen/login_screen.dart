import 'package:flutter/material.dart';
import 'package:to_do_list/widgets/AppButton.dart';
import 'package:to_do_list/widgets/form_field.dart';
import 'package:to_do_list/screens/register_screen/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final bool isLoading = false;

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
                Text("Zaloguj sie abu zacząć zapisywać i dzielić sie swoimi zadaniami.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                FormFieldWidget(
                  controller: _emailController,
                  isPassword: false,
                  icon: Icons.email,
                  hintText: "Email",
                  validator: (value) => emailValidator(value),
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
                      return "Pole Hasło jest za krótkie! (min. 6 znaków)";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AppButton(title: "Zaloguj się",onPressed:() {
                  if(_formKey.currentState!.validate()) {
                    print("Logowanie działa");
                  }
                },isLoading: isLoading),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen())
                    ),
                  },
                  child: Text("Nie masz konta? Zarejestruj się!"),
                )
              ],
            ),
          ),
        ),
      ),
    ),
  );

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "To pole nie może być puste!";
    }
    // Bardziej rygorystyczny regex dla maila
    final emailRegex = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!emailRegex.hasMatch(value)) {
      return "Podaj prawidłowy format maila.";
    }
    return null;
  }
}
