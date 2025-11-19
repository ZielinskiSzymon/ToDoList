import 'package:flutter/material.dart';
class FormFieldWidget extends StatefulWidget {
  const FormFieldWidget({
    super.key,
    required this.controller,
    required this.isPassword,
    required this.icon,
    required this.hintText,
    this.validator, // Nowy opcjonalny validator
  });

  final TextEditingController? controller;
  final bool isPassword;
  final IconData icon;
  final String hintText;
  final String? Function(String?)? validator; // Typ dla walidatora

  @override
  State<FormFieldWidget> createState() => _FormFieldWidgetState();
}

class _FormFieldWidgetState extends State<FormFieldWidget> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: widget.controller,
    obscureText: widget.isPassword ? _obscureText : false,
    decoration: InputDecoration(
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20)
      ),
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(width: 2), // Dodano const
          borderRadius: BorderRadius.circular(20)
      ),
      prefixIcon: Icon(widget.icon),
      hintText: widget.hintText,
      suffixIcon: widget.isPassword
          ? IconButton(
        icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
        onPressed: () => setState(() => _obscureText = !_obscureText),
      )
          : null,
    ),
    validator: widget.validator,
  );
}