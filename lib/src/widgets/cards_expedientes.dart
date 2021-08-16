
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medicpro/src/models/expedientes_model.dart';

class CardsExpedintes extends StatelessWidget {
  final ExpedienteModel expdiente; 
 const CardsExpedintes({required this.expdiente });
  @override
  Widget build(BuildContext context) { 
    return Container(
      margin: EdgeInsets.all(10),
      child: Material(
        borderRadius: BorderRadius.circular(15),
        elevation: 5,
        child: ListTile(
          tileColor: Color(0xffF9F9F9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(50.0),
            child: FadeInImage(
              placeholder: AssetImage("assets/imgs/no-image.png"),
              image: NetworkImage(expdiente.getImg),
              fadeInCurve: Curves.easeIn,
              fadeInDuration: Duration(seconds: 1),
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/imgs/no-image.png');
              },
            ),
          ),
          trailing: FaIcon(FontAwesomeIcons.chevronRight),
          title: Text(expdiente.nombre + " " + expdiente.apellido  ),
          subtitle: Text(expdiente.fecha_nacimiento),
        ),
      ),
    );
  }
}
