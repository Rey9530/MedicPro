import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medicpro/src/models/expedientes_model.dart';

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
          return _CardsExpedintes(expdiente: widget.listExpedientes[i], i:i);
        },
      ),
    );
  }
}

class _CardsExpedintes extends StatelessWidget {
  final ExpedienteModel expdiente;
  final int  i;

  const _CardsExpedintes({required this.expdiente, required this.i});
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
          title: Text(expdiente.nombre + " " + expdiente.apellido + " " + this.i.toString()),
          subtitle: Text(expdiente.fecha_nacimiento),
        ),
      ),
    );
  }
}
