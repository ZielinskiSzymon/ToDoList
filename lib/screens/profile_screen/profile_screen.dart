import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../login_screen/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => singOut(context),
              child: const Icon(Icons.logout),
            ),
            const SizedBox(height: 20),
            Text("Profil")
          ],
        ),
      ),
    ),
  );

  Future<void> singOut(BuildContext context) async {
    try {
      final supabase = Supabase.instance.client;

      await supabase.auth.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false);
      }
    } catch (err) {
      print(err.toString());
    }
  }
}
