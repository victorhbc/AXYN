import 'package:flutter/material.dart';

/// Reusable text field with consistent styling
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final bool enabled;

  const AppTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
    );
  }
}
