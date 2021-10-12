import 'package:flutter/material.dart';

Route CrearRuta(pagina) {
  return PageRouteBuilder(
    pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) =>
        pagina,
    transitionDuration: Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curveAniumation =
          CurvedAnimation(parent: animation, curve: Curves.easeIn);
      return ScaleTransition(
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(curveAniumation),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curveAniumation),
          child: child,
        ),
      );
    },
  );
}