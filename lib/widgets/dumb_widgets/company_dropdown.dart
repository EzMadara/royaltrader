import 'package:flutter/material.dart';

class DropdownField extends StatelessWidget {
  final String? value;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;
  final bool isFloatLabel;

  const DropdownField({
    super.key,
    required this.value,
    required this.onChanged,
    this.validator,
    this.isFloatLabel = false,
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
        labelText: 'Company Name',
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
      items: const [
        DropdownMenuItem(
          value: 'Oreal ceramics',
          child: Text('Oreal ceramics'),
        ),
        DropdownMenuItem(value: 'Time ceramics', child: Text('Time ceramics')),
        DropdownMenuItem(value: 'Stile', child: Text('Stile')),
        DropdownMenuItem(value: 'Cereamic', child: Text('Cereamic')),
      ],
      onChanged: onChanged,
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a company name';
            }
            return null;
          },
    );
  }
}
