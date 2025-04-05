import 'package:flutter/material.dart';

class AppTextField2 extends StatelessWidget {
  final String labelText;
  final String helpText;
  final bool isFloatLabel;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final Function()? onTap;
  final bool readOnly;
  final int? maxLines;
  final InputDecoration? decoration;
  final TextInputAction? textInputAction;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final FocusNode? focusNode;

  const AppTextField2({
    Key? key,
    required this.labelText,
    required this.helpText,
    required this.isFloatLabel,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.decoration,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onTap: onTap,
      readOnly: readOnly,
      maxLines: maxLines,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      focusNode: focusNode,
      decoration:
          decoration ??
          InputDecoration(
            labelText: isFloatLabel ? labelText : null,
            hintText: helpText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            suffixIcon: suffixIcon,
            labelStyle: TextStyle(color: Theme.of(context).primaryColor),
            // Used when isFloatLabel is false
            filled: !isFloatLabel,
            fillColor: !isFloatLabel ? Colors.grey.shade100 : null,
            floatingLabelBehavior:
                isFloatLabel
                    ? FloatingLabelBehavior.auto
                    : FloatingLabelBehavior.never,
          ),
      style: const TextStyle(fontSize: 16),
    );
  }
}
