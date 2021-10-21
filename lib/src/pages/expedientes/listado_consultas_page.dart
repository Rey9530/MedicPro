import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medicpro/src/models/models.dart';
import 'package:medicpro/src/providers/providers.dart';
import 'package:medicpro/src/themes/theme.dart';
import 'package:medicpro/src/widgets/widgets.dart';
import 'package:provider/provider.dart';

class ListadoConsultasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ExpedienteInformacion>(
            create: (_) => ExpedienteInformacion()),
      ],
      child: Scaffold(
        body: BodyListConsultas(),
      ),
    );
  }
}

class BodyListConsultas extends StatefulWidget {
  @override
  _BodyListConsultasState createState() => _BodyListConsultasState();
}

class _BodyListConsultasState extends State<BodyListConsultas> {
  @override
  Widget build(BuildContext context) {
    final providerExpediente = Provider.of<ExpedientesProvider>(context);
    final consultasList = Provider.of<ExpedienteInformacion>(context, listen: false);
  

    return Column(
      children: [
        AppBardCustomerEdit(providerExpediente.expeidnteSeleted!),
        FutureBuilder(
        future: consultasList.getAllConsultas(providerExpediente.expeidnteSeleted!.token_expediente),
          builder: (BuildContext context, AsyncSnapshot<List<Consulta>> snapshot) {
            if(!snapshot.hasData){
              return Expanded(
                child: Center( 
                  child: CircularProgressIndicator( color: temaApp.primaryColor, )
                ),
              );
            }
            
            final List<Consulta> consultas = snapshot.data!;

             if (consultas.length == 0) {
                return Expanded(
                  child: LoadingIndicater(),
                );
              }
            return Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: consultas.length,
                itemBuilder: (_, i) {
                  String url = consultas[i].getUrl();
                  if(consultas[i].ruta==null || consultas[i].ruta==""){
                      url = "N/A";
                  }
                  return ViewListPdf(url:url, title: consultas[i].fecha+" (${ consultas[i].tipoFicha }) ");
                },
              ),
            );
          },
        ),
        
      ],
    );
  }

  _consultaItem(Consulta consultas, int i) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: Material(
        borderRadius: BorderRadius.circular(25),
        elevation: 5,
        child: 

        
        
        ExpansionTile(
          title: Text(consultas.fecha),
          subtitle: Text(consultas.tipoFicha),
          trailing: Icon( 
            consultas.isExpander
                ? Icons.arrow_drop_down_circle
                : Icons.arrow_drop_down,
          ),
          expandedAlignment: Alignment.topLeft,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                   FaIcon( FontAwesomeIcons.filePdf ),
                ],
              ),
            ), // 
          ],
          onExpansionChanged: (bool expanded) {
            /*setState(() {
              consultas.isExpander = expanded; 
            });*/
          },
        ),
      ),
    );
  }
}
