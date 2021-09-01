import 'package:flutter/material.dart';
import 'package:medicpro/src/themes/theme.dart';

class HeaderBackGround extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 350,
      decoration: BoxDecoration(
        color: temaApp.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: const Radius.circular(75),
          bottomRight: const Radius.circular(75),
        ),
      ),
    );
  }
}