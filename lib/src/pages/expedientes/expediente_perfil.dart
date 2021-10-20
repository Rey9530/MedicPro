import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medicpro/src/models/expedientes_model.dart';
import 'package:medicpro/src/pages/pages.dart';
import 'package:medicpro/src/providers/providers.dart';
import 'package:medicpro/src/themes/theme.dart';
import 'package:medicpro/src/widgets/widgets.dart';
import 'package:provider/provider.dart';

class ExpedientePerfilPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final providerExpediente = Provider.of<ExpedientesProvider>(context);
    return Scaffold(
      body: Container(
        color: temaApp.backgroundColor,
        child: Stack(
          children: [
            HeaderBackGround(),
            SafeArea(child: Body(providerExpediente.expeidnteSeleted!)),
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
        AppBardCustomer(expediente),
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
              Opcion(
                icono: FontAwesomeIcons.hospitalAlt,
                titulo: "Consultas",
                funcionEjecutar: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListadoConsultasPage(),
                    ),
                  );
                },
              ), 
              Opcion(
                icono: FontAwesomeIcons.images,
                titulo: "Imagenes",
                funcionEjecutar: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImagenesExpdientesPage(),
                    ),
                  );
                },
              ),
              Opcion(
                icono: FontAwesomeIcons.file,
                titulo: "Documentos",
                funcionEjecutar: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExpedientesDocumentosPage(),
                    ),
                  );
                },
              ),
              Opcion(
                icono: FontAwesomeIcons.paperclip,
                titulo: "Archivos",
                funcionEjecutar: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExpedientesArchivosPage(),
                    ),
                  );
                },
              ),
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
  Function funcionEjecutar;

  Opcion(
      {required this.titulo,
      required this.icono,
      required this.funcionEjecutar});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => this.funcionEjecutar(),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        width: double.infinity,
        height: 50,
        child: Material(
          borderRadius: BorderRadius.circular(40),
          elevation: 5,
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Expanded(
                  child: Container(),
                ),
                FaIcon(FontAwesomeIcons.chevronRight),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CardInfo extends StatelessWidget {
  final ExpedienteModel expediente;

  const CardInfo(this.expediente);
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
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          expediente.telCelular.toString(),
                          style: TextStyle(fontSize: 16),
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
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          expediente.sexo,
                          style: TextStyle(fontSize: 16),
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
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          expediente.fecha_nacimiento,
                          style: TextStyle(fontSize: 16),
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
  const HeaderProfile(this.expediente);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 140,
      padding: EdgeInsets.only(left: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Hero(
            tag: expediente.token_expediente,
            child: ImagenPerfil(
              height: 125,
              radius: 125,
              urlImagePerfil: expediente.getImg,
              width: 125,
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expediente.nombre + " " + expediente.apellido,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: temaApp.backgroundColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  Text(
                    expediente.email.toString(),
                    style: TextStyle(
                      fontSize: 14,
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
  final ExpedienteModel expedinte;
  const AppBardCustomer(this.expedinte);

  @override
  Widget build(BuildContext context) {
    final providerExpediente = Provider.of<ExpedientesProvider>(context);
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
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExpedienteEditePage(),
                ),
              );
            },
            child: Icon(
              FontAwesomeIcons.userEdit,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
