import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String? value;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;
  final bool isFloatLabel;
  final String labelText;
  final List<String> items;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.validator,
    this.isFloatLabel = false,
    required this.labelText,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFCCD0D4), width: 1.1),
          borderRadius: BorderRadius.circular(4),
        ),
        labelText: labelText,
        floatingLabelBehavior:
            isFloatLabel
                ? FloatingLabelBehavior.always
                : FloatingLabelBehavior.never,
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFCCD0D4), width: 1.1),
          borderRadius: BorderRadius.circular(4),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 1.1),
          borderRadius: BorderRadius.circular(4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 1.4),
          borderRadius: BorderRadius.circular(4),
        ),
        fillColor: !isFloatLabel ? Colors.grey.shade100 : null,
      ),
      dropdownColor: Colors.white,
      value: value,
      items:
          items.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
      onChanged: onChanged,
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please select $labelText';
            }
            return null;
          },
    );
  }
}
