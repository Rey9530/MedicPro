import 'package:flutter/material.dart';
import 'package:medicpro/src/themes/theme.dart';

class LoadingIndicater extends StatelessWidget {
  const LoadingIndicater({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: temaApp.primaryColor,
      ),
    );
  }
}
