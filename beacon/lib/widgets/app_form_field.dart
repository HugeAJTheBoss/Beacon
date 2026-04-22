import 'package:flutter/material.dart';

import '../app_theme.dart';

class AppFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final FormFieldValidator<String> validator;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final int maxLines;

  const AppFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.autofillHints,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveKeyboardType = maxLines > 1
        ? TextInputType.multiline
        : keyboardType;
    // Multi-line fields should open a new line instead of advancing focus.
    final effectiveTextInputAction =
        textInputAction ??
        (maxLines > 1 ? TextInputAction.newline : TextInputAction.next);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: TextFormField(
        controller: controller,
        keyboardType: effectiveKeyboardType,
        textInputAction: effectiveTextInputAction,
        autofillHints: autofillHints,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, hintText: hint),
        validator: validator,
      ),
    );
  }
}
