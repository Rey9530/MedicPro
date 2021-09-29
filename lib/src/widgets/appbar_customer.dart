import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medicpro/src/models/models.dart';
import 'package:medicpro/src/themes/theme.dart';

class AppBardCustomerEdit extends StatelessWidget {
  final ExpedienteModel expedinte;
  const AppBardCustomerEdit(this.expedinte);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(15),
        bottomRight: Radius.circular(15),
      ),
      child: Container(
        padding: EdgeInsets.only(left: 15, right: 15, top: 30,),
        width: double.infinity,
        decoration: BoxDecoration(
          color: temaApp.primaryColor,
        ),
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 30,
                height: 30,
                child: FaIcon(
                  FontAwesomeIcons.chevronLeft,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Text(
                expedinte.nombre + " " + expedinte.apellido,
                style: TextStyle(
                  color: temaApp.backgroundColor,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
    );
  }
}
