import 'package:flutter/material.dart';

class LoginFormProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  String usuario = '';
  String password = '';

  bool _isLoadin = false;
  bool get isLoadin => _isLoadin;

  set isLoadin(bool value) {
    _isLoadin = value;
    notifyListeners();
  }

  bool isValiForm() {
    return formKey.currentState?.validate() ?? false;
  }
}
