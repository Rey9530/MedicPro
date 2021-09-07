import 'package:flutter/material.dart';
import 'package:medicpro/src/themes/theme.dart';

void showAlertDialog(BuildContext context, String titulo, String subtitulo) {
  // set up the button
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    contentPadding: const EdgeInsets.all(10),
    contentTextStyle:
        TextStyle(color: temaApp.primaryColor, fontWeight: FontWeight.w600),
    titleTextStyle: TextStyle(
      color: temaApp.primaryColor,
      fontWeight: FontWeight.bold,
      fontSize: 20.0,
    ),
    title: Center(child: Text(titulo)),
    content: Container( width: double.infinity, height: 15, child: Center(child: Text(subtitulo))),
    elevation: 24,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20.0)),
    ),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
