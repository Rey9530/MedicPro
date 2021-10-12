import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medicpro/src/themes/theme.dart';
import 'package:select_form_field/select_form_field.dart';

class Select2 extends StatelessWidget {
  final dynamic initialValue;
  final List<Map<String, dynamic>> items;
  final String placeholder;
  final String label;
  final IconData prefix;
  final Function validacion;

  const Select2({
    required this.initialValue,
    required this.placeholder,
    required this.label,
    required this.validacion,
    required this.items,
    required this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: SelectFormField(
        style: TextStyle(
          color: temaApp.primaryColor,
        ),
        cursorColor: temaApp.primaryColor,
        type: SelectFormFieldType.dropdown, // or can be dialog
        initialValue: this.initialValue,
        icon: FaIcon(
          this.prefix,
          color: temaApp.primaryColor,
        ),
        labelText: this.label,
        items: this.items,
        onChanged: ((value) {
          this.validacion(value);
        }),
        onSaved: (val) => this.validacion,
      ),
    );
  }
}