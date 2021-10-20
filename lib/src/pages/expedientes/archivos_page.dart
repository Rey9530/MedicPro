import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medicpro/src/models/models.dart';
import 'package:medicpro/src/pages/pages.dart';
import 'package:medicpro/src/providers/providers.dart';
import 'package:medicpro/src/widgets/widgets.dart';
import 'package:provider/provider.dart';

class ExpedientesArchivosPage extends StatelessWidget {
  const ExpedientesArchivosPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ExpedienteInformacion>(
          create: (_) => ExpedienteInformacion(),
        ),
      ],
      child: Scaffold(body: ArchivosWidgetPage()),
    );
  }
}

class ArchivosWidgetPage extends StatelessWidget {
  const ArchivosWidgetPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final providerExpediente =
        Provider.of<ExpedientesProvider>(context, listen: false);
    return Stack(
      children: [
        AppBardCustomerEdit(providerExpediente.expeidnteSeleted!),
        Container(
            margin: EdgeInsets.only(top: 60),
            child: ArchivosExp( providerExpediente.expeidnteSeleted!.token_expediente))
      ],
    );
  }
}

class ArchivosExp extends StatelessWidget {
  final String tokenExpediente;
  const ArchivosExp(this.tokenExpediente);
  @override
  Widget build(BuildContext context) {
    final informacion =
        Provider.of<ExpedienteInformacion>(context, listen: false);
    return FutureBuilder(
      future: informacion.getArchivos(this.tokenExpediente),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return LoadingIndicater();
        }
        final List<Archivo> documentos = snapshot.data!;

        if (documentos.length == 0) {
          return Center(
            child: FaIcon(
              FontAwesomeIcons.file,
              size: 80,
              color: Colors.black12,
            ),
          );
        }
        return ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: documentos.length,
          itemBuilder: (_, i) {
            String title = "N/A";
            if (documentos[i].descripcion != null) {
              title = documentos[i].descripcion!;
            }
            if (documentos[i].tipo == "pdf") {
              return ViewListPdf(url: documentos[i].getUrl(), title: title);
            } else {
              return ViewImages(url: documentos[i].getUrl(), title: title);
            }
          },
        );
      },
    );
  }
}

class ViewImages extends StatelessWidget {
  const ViewImages({
    Key? key,
    required this.url,
    required this.title,
  }) : super(key: key);

  final String url;
  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewImage(url, this.title),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        child: Material(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          elevation: 5,
          child: ListTile(
            leading: FaIcon(FontAwesomeIcons.solidImage),
            title: Text(this.title),
          ),
        ),
      ),
    );
  }
}

class ViewImage extends StatelessWidget {
  final String urlBase;
  final String title;
  const ViewImage(this.urlBase, this.title);

  @override
  Widget build(BuildContext context) {
    final query = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child:
            ImagenEnRed(
                fit: BoxFit.contain,
                height: double.infinity,
                width: query.width,
                img: urlBase,
                center: true,
            ) 
          ),
          AppBarrImage(),
        ],
      ),
    );
  }
}
