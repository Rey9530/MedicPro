import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medicpro/src/models/models.dart';
import 'package:medicpro/src/providers/providers.dart';
import 'package:medicpro/src/themes/theme.dart';
import 'package:medicpro/src/widgets/widgets.dart';
import 'package:provider/provider.dart';

class ListadoConsultasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final providerExpediente =
        Provider.of<ExpedientesProvider>(context, listen: false);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ExpedienteInformacion>(
            create: (_) => ExpedienteInformacion()),
      ],
      child: Scaffold(
        body: Stack(
          children: [
            BodyListConsultas(providerExpediente.expeidnteSeleted!.token_expediente),
            AppBardCustomerEdit(providerExpediente.expeidnteSeleted!),
          ],
        ),
      ),
    );
  }
}

class BodyListConsultas extends StatefulWidget {
  final String tokenExpediente;

  const BodyListConsultas(this.tokenExpediente);
  @override
  _BodyListConsultasState createState() => _BodyListConsultasState();
}

class _BodyListConsultasState extends State<BodyListConsultas> {
  @override
  Widget build(BuildContext context) {
    final consultasList =
        Provider.of<ExpedienteInformacion>(context, listen: false);

    return Container(
      child: FutureBuilder(
        future: consultasList.getAllConsultas(widget.tokenExpediente),
        builder:
            (BuildContext context, AsyncSnapshot<List<Consulta>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
              color: temaApp.primaryColor,
            ));
          } 
          final List<Consulta> consultas = snapshot.data!;

          if (consultas.length == 0) {
            return Center(
              child: FaIcon(
                FontAwesomeIcons.filePdf,
                size: 80,
                color: Colors.black12,
              ),
            );
          }
          return Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: consultas.length,
              itemBuilder: (_, i) {
                String url = consultas[i].getUrl();
                if (consultas[i].ruta == null || consultas[i].ruta == "") {
                  url = "N/A";
                }
                return ViewListPdf(
                    url: url,
                    title:
                        consultas[i].fecha + " (${consultas[i].tipoFicha}) ");
              },
            ),
          );
        },
      ),
    );
  }
}
