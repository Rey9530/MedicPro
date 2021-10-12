import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medicpro/src/ui/input_decorations.dart';
class InputsExpediente extends StatelessWidget {
  final String valor;
  final String placeholder;
  final String label;
  final TextInputType keyboardType;
  final IconData prefix;
  final Function validacion;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;

  const InputsExpediente({
    required this.valor,
    required this.placeholder,
    required this.label,
    required this.prefix,
    required this.validacion,
    required this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        maxLines: this.maxLines,
        initialValue: valor,
        autocorrect: false,
        keyboardType: keyboardType,
        decoration: InputDecorations.authInputDecoration(
          hintText: this.placeholder,
          labelText: this.label,
          prefixIcon: this.prefix,
        ),
        inputFormatters: this.inputFormatters,
        validator: ((value) {
          this.validacion(value);
        }),
        onChanged: ((value) {
          this.validacion(value);
        }),
      ),
    );
  }
}