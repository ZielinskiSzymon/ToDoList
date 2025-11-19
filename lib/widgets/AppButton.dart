// AppButton.dart (Zmiana)
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({super.key, required this.title, this.onPressed, required this.isLoading});
  final String title;
  final VoidCallback? onPressed;
  final bool isLoading;

  static const double _borderRadius = 12;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF0a0a0a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRadius)),
      ),
      onPressed: onPressed,
      child: isLoading ? CircularProgressIndicator(color: Colors.white, padding: EdgeInsets.all(6)) : Text(
          title,
          style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600
          )
      ),
    ),
  );
}