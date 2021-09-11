import 'package:flutter/material.dart';
import 'package:medicpro/src/models/models.dart';
import 'package:medicpro/src/providers/providers.dart';
import 'package:medicpro/src/widgets/widgets.dart';
import 'package:provider/provider.dart';

class ListadoConsultasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ExpedienteInformacion>(create: (_) => ExpedienteInformacion()),
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
  void initState() {
    // TODO: implement initState
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providerExpediente = Provider.of<ExpedientesProvider>(context);
    final consultasList = Provider.of<ExpedienteInformacion>(context);
    consultasList
        .getAllConsultas(providerExpediente.expeidnteSeleted!.token_expediente);
    return Column(
      children: [
        AppBardCustomerEdit(providerExpediente.expeidnteSeleted!),
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: consultasList.consultas.length,
            itemBuilder: (_, i) {
              return _consultaItem(consultasList.consultas[i], i);
            },
          ),
        ),
      ],
    );
  }

  _consultaItem(Consulta consultas, int i) {
    return Container(
      margin: EdgeInsets.all(5),
      child: Material(
        borderRadius: BorderRadius.circular(25),
        elevation: 5,
        child: ExpansionTile(
          title: Text(consultas.fecha),
          subtitle: Text(consultas.tipoFicha),
          trailing: Icon(
            //consultasList.consultas[i].fecha.toString()
            consultas.isExpander
                ? Icons.arrow_drop_down_circle
                : Icons.arrow_drop_down,
          ),
          expandedAlignment: Alignment.centerLeft,
          children: <Widget>[
            ListTile(title: Text(consultas.medico)), //
            Container(child: Icon(Icons.elderly_sharp))
          ],
          onExpansionChanged: (bool expanded) {
            setState(() => consultas.isExpander = expanded);
          },
        ),
      ),
    );
  }
}
