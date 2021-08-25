import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medicpro/src/models/expedientes_model.dart';
import 'package:medicpro/src/themes/theme.dart';

class ExpedientePerfilPage extends StatelessWidget {
  final ExpedienteModel expediente;

  const ExpedientePerfilPage({Key? key, required this.expediente})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: temaApp.backgroundColor,
        child: Stack(
          children: [
            BackGround(),
            SafeArea(child: Body(expediente)),
          ],
        ),
      ),
    );
  }
}

class Body extends StatelessWidget {
  final ExpedienteModel expediente;

  const Body(this.expediente);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBardCustomer(),
        HeaderProfile(expediente),
        CardInfo(expediente),
        Opciones(),
      ],
    );
  }
}

class Opciones extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(top: 10),
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(color: temaApp.backgroundColor),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Opcion("Consultas", FontAwesomeIcons.hospitalAlt),
              Opcion("Citas", FontAwesomeIcons.calendarCheck),
              Opcion("Imagenes", FontAwesomeIcons.images),
              Opcion("Documentos", FontAwesomeIcons.file),
              Opcion("Archivos", FontAwesomeIcons.paperclip),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class Opcion extends StatelessWidget {
  String titulo;
  IconData icono;

  Opcion(this.titulo, this.icono);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      width: double.infinity,
      height: 50,
      child: Material(
        borderRadius: BorderRadius.circular(40),
        elevation: 10,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: FaIcon(icono),
                width: 30,
                alignment: Alignment.center,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                titulo,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Expanded(
                child: Container(),
              ),
              FaIcon(FontAwesomeIcons.chevronRight),
            ],
          ),
        ),
      ),
    );
  }
}

class CardInfo extends StatelessWidget {
  final ExpedienteModel expediente;

  const CardInfo( this.expediente);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: double.infinity,
      height: 180,
      child: Material(
        borderRadius: BorderRadius.circular(30),
        elevation: 10,
        child: Container(
          margin: EdgeInsets.all(20),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          child: FaIcon(FontAwesomeIcons.phone),
                          width: 30,
                        ),
                        Text(
                          "Telefono:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        Text(
                          expediente.telCelular.toString(),
                          style: TextStyle(fontSize: 20),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          child: FaIcon(FontAwesomeIcons.venus),
                          width: 30,
                        ),
                        Text(
                          "Sexo: ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        Text(
                          expediente.sexo,
                          style: TextStyle(fontSize: 20),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          child: FaIcon(FontAwesomeIcons.calendarAlt),
                          width: 30,
                        ),
                        Text(
                          "F. Nacimiento:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        Text(
                          expediente.fecha_nacimiento,
                          style: TextStyle(fontSize: 20),
                        )
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class HeaderProfile extends StatelessWidget {
  final ExpedienteModel expediente;

  const HeaderProfile( this.expediente);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 140,
      padding: EdgeInsets.only(left: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(125),
            child: FadeInImage(
              width: 125,
              height: 125,
              fit: BoxFit.fill,
              placeholder: AssetImage("assets/imgs/no-image.png"),
              image: NetworkImage(expediente.getImg),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expediente.nombre+" "+expediente.apellido,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: temaApp.backgroundColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  Text(
                    "Demostracion",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: temaApp.backgroundColor,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AppBardCustomer extends StatelessWidget {
  const AppBardCustomer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      width: double.infinity,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          Icon(
            FontAwesomeIcons.userEdit,
            color: Colors.white,
          )
        ],
      ),
    );
  }
}

class BackGround extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 350,
      decoration: BoxDecoration(
        color: temaApp.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(75),
          bottomRight: Radius.circular(75),
        ),
      ),
    );
  }
}
