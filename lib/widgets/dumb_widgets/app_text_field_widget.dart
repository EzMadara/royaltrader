import 'dart:convert';

import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String labelText;
  final bool isObscured;
  final TextInputType type;
  final helpText;
  final Widget? suffix;
  final isFloatLabel;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    required this.labelText,
    this.isObscured = false,
    this.type = TextInputType.text,
    this.helpText,
    this.suffix,
    this.isFloatLabel = true,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      controller: controller,

      obscureText: isObscured,
      keyboardType: type,
      decoration: InputDecoration(
        floatingLabelBehavior:
            isFloatLabel
                ? FloatingLabelBehavior.always
                : FloatingLabelBehavior.never,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFCCD0D4), width: 1.1),
          borderRadius: BorderRadius.circular(4),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 1.1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        labelText: labelText,
        hintText: helpText,
        suffix: suffix,
        labelStyle: Theme.of(context).textTheme.bodyLarge,
        hintStyle: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
