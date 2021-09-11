import 'package:flutter/material.dart';
import 'package:medicpro/src/providers/providers.dart';
import 'package:provider/provider.dart';

class ConsultasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final consultasList = Provider.of<ExpedienteInformacion>(context);
    return Scaffold(
      body: Center(
        child: Text('Hola Mundo'),
      ),
    );
  }
}
