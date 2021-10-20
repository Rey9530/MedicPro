import 'package:flutter/material.dart';
import 'package:medicpro/src/themes/theme.dart';

class SplashPage extends StatelessWidget {
  const SplashPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(bottom: 80),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Image(
                width: 300,
                image: AssetImage("assets/imgs/icono_medicpro.png"),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(temaApp.primaryColor),
              ),
            )
          ],
        ),
      ),
    );
  }
}
