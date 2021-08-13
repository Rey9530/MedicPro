import 'package:flutter/material.dart';
import 'package:medicpro/src/themes/theme.dart';

class InputDecorations {
  static InputDecoration authInputDecoration({
    required String hintText,
    required String labelText,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: temaApp.primaryColor, width: 1),
          borderRadius: BorderRadius.circular(100),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: temaApp.primaryColor, width: 2),
          borderRadius: BorderRadius.circular(100),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        hintText: hintText,
        labelText: labelText,
        labelStyle: TextStyle(
          color: Colors.grey,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: temaApp.primaryColor)
            : null);
  }
}
