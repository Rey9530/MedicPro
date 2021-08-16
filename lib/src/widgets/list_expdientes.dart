import 'package:flutter/material.dart'; 
import 'package:medicpro/src/models/expedientes_model.dart';
import 'package:medicpro/src/widgets/widgets.dart';

class ListExpdientes extends StatefulWidget {
  final List<ExpedienteModel> listExpedientes;
  final Function hacellamada;

  const ListExpdientes(
      {required this.listExpedientes, required this.hacellamada});
  @override
  _ListExpdientesState createState() => _ListExpdientesState();
}

class _ListExpdientesState extends State<ListExpdientes> {
  final ScrollController scrollController = new ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    scrollController.addListener(() { 
      if ((scrollController.position.maxScrollExtent - 50) <=
          scrollController.position.pixels) {
        //TODO
        widget.hacellamada();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.vertical,
        itemCount: widget.listExpedientes.length,
        itemBuilder: (_, i) {
          return CardsExpedintes(expdiente: widget.listExpedientes[i] );
        },
      ),
    );
  }
}
 
