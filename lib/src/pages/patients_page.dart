import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medicpro/src/providers/expedientes_provider.dart';
import 'package:medicpro/src/searchs/search_paciente.dart';
import 'package:medicpro/src/themes/theme.dart';
import 'package:medicpro/src/widgets/widgets.dart';
import 'package:provider/provider.dart';

class PatientsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final expedientesProvider = Provider.of<ExpedientesProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: temaApp.primaryColor,
        title: Text(
          "Expedientes",
          style: TextStyle(color: temaApp.backgroundColor),
        ),
        elevation: 0,
        actions: [_BotonBuscar()],
      ),
      backgroundColor: temaApp.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListExpdientes(
            listExpedientes: expedientesProvider.lisExpdientes,
            hacellamada: () => expedientesProvider.getAllExpedientes(),
          ),
          (expedientesProvider.isLoading)
              ? Container( margin: EdgeInsets.only(bottom: 20), child: Center(child: CircularProgressIndicator()))
              : Container()
        ],
      ),
    );
  }
}

class _BotonBuscar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.search_outlined,
      ),
      onPressed: () {
        showSearch(context: context, delegate: ExpedientesSeach() );
      },
    );
  }
}
