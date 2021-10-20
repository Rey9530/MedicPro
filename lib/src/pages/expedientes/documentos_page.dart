import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medicpro/src/models/models.dart';
// import 'package:medicpro/src/pages/pages.dart';
import 'package:medicpro/src/providers/providers.dart';
// import 'package:medicpro/src/themes/theme.dart';
import 'package:medicpro/src/widgets/widgets.dart';
import 'package:provider/provider.dart';

class ExpedientesDocumentosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ExpedienteInformacion>(
          create: (_) => ExpedienteInformacion(),
        ),
      ],
      child: Scaffold(
        body: Container(
          child: CuerpoDocumentos(),
        ),
      ),
    );
  }
}

class CuerpoDocumentos extends StatelessWidget {
  const CuerpoDocumentos({
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
          child: ListDocumentos(providerExpediente),
        )
      ],
    );
  }
}

class ListDocumentos extends StatelessWidget {
  final ExpedientesProvider providerExpediente;
  const ListDocumentos(this.providerExpediente);

  @override
  Widget build(BuildContext context) {
    final consultasList =
        Provider.of<ExpedienteInformacion>(context, listen: false);
    return FutureBuilder(
      future: consultasList
          .getDocumentos(providerExpediente.expeidnteSeleted!.token_expediente),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) { 
          return LoadingIndicater();
        }
        final List<ExpDocumento> documentos = snapshot.data!;

        if (documentos.length == 0) {
          return Center(
            child: FaIcon(
              FontAwesomeIcons.filePdf,
              size: 80,
              color: Colors.black12,
            ),
          );
        }

        return ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: documentos.length,
          itemBuilder: (_, i) {
            return ViewListPdf(url:documentos[i].getUrl(), title: documentos[i].tipoplantilla);
          },
        );
      },
    );
  }
}

