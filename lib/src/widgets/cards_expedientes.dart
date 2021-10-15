import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medicpro/src/models/expedientes_model.dart';
import 'package:medicpro/src/pages/pages.dart';
import 'package:medicpro/src/providers/providers.dart';
import 'package:medicpro/src/widgets/widgets.dart';
import 'package:provider/provider.dart';

class CardsExpedintes extends StatelessWidget {
  final ExpedienteModel expdiente;
  const CardsExpedintes({required this.expdiente});
  @override
  Widget build(BuildContext context) {
    final providerExpediente = Provider.of<ExpedientesProvider>(context);
    return GestureDetector(
      onTap: () {
        providerExpediente.expeidnteSeleted = expdiente.copy();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExpedientePerfilPage(),
          ),
        );
      },
      child: Container(
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
              child: ImagenEnRed(fit: BoxFit.cover, height: 50, img: expdiente.getImg, width: 50,),
 
            ),
            trailing: FaIcon(FontAwesomeIcons.chevronRight),
            title: Text(expdiente.nombre + " " + expdiente.apellido),
            subtitle: Text(expdiente.fecha_nacimiento),
          ),
        ),
      ),
    );
  }
}
