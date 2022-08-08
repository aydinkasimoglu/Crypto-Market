import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField(
      {Key? key,
      required this.controller,
      required this.prefixIcon,
      required this.borderText,
      required this.onChanged})
      : super(key: key);

  final TextEditingController controller;
  final String borderText;
  final Icon prefixIcon;
  final void Function(String value) onChanged;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        prefixIcon: widget.prefixIcon,
        labelText: widget.borderText,
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        CustomTextInputFormatter(),
      ],
    );
  }
}

class CustomTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (oldValue.text.isEmpty && newValue.text == '.') {
      newValue = const TextEditingValue(
        text: '0.',
        selection: TextSelection.collapsed(offset: 2),
      );
    }

    if (newValue.text.contains('.') &&
        newValue.text.substring(newValue.text.indexOf('.')).length > 4) {
      newValue = oldValue;
    }

    if (RegExp(r'([ \-\,A-Za-z])|(\..*\.)').hasMatch(newValue.text)) {
      newValue = oldValue;
    }

    return newValue;
  }
}
