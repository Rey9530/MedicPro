import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medicpro/src/pages/expedientes/expedientes_imagenes_datelle_page.dart';
import 'package:medicpro/src/pages/pages.dart';
import 'package:medicpro/src/providers/providers.dart';
import 'package:medicpro/src/themes/theme.dart';
import 'package:medicpro/src/utils/variables.dart';
import 'package:medicpro/src/widgets/widgets.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

class ImagenesExpdientesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final providerExpediente = Provider.of<ExpedientesProvider>(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ExpedienteInformacion>(
          create: (_) => ExpedienteInformacion(),
        ),
      ],
      child: Container(
        child: CuerpoImagenes(providerExpediente: providerExpediente),
      ),
    );
  }
}

class CuerpoImagenes extends StatelessWidget {
  const CuerpoImagenes({
    Key? key,
    required this.providerExpediente,
  }) : super(key: key);

  final ExpedientesProvider providerExpediente;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (providerExpediente.isSavin)
          ? Center(
              child: Center(
                child: CircularProgressIndicator(
                  color: temaApp.primaryColor,
                ),
              ),
            )
          : Stack(
              children: [
                FutureImages(
                    tokenExpediente:
                        providerExpediente.expeidnteSeleted!.token_expediente),
                AppBardCustomerEdit(providerExpediente.expeidnteSeleted!),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: temaApp.primaryColor,
        child: FaIcon(
          FontAwesomeIcons.camera,
          color: temaApp.backgroundColor,
        ),
        onPressed: () => showMaterialModalBottomSheet(
          expand: false,
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => ModalFit(
            perfil: false,
            ruta: EditarImagenPage(),
          ),
        ),
      ),
    );
  }
}

class FutureImages extends StatelessWidget {
  final String tokenExpediente;
  const FutureImages({
    required this.tokenExpediente,
  });

  @override
  Widget build(BuildContext context) {
    final consultasList =  Provider.of<ExpedienteInformacion>(context, listen: false);
    return Container(
      margin: const EdgeInsets.only(top: 50),
      child: FutureBuilder(
        future: consultasList.getIamgesExpedientes(this.tokenExpediente),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (!snapshot.hasData) {
              return LoadingIndicater(); 
          }
          final List fotos = snapshot.data!;

          if (fotos.length == 0) {
            return Center(
              child: FaIcon(
                FontAwesomeIcons.images,
                size: 80,
                color: Colors.black12,
              ),
            );
          }
          return new StaggeredGridView.countBuilder(
            crossAxisCount: 4,
            itemCount: fotos.length,
            itemBuilder: (BuildContext context, int index) => GestureDetector(
              onTap: () {
                Navigator.push(
                    context, CrearRuta(ImagenesDetallePage(index, fotos)));
              },
              child: new Container(
                child: Hero(
                  tag: fotos[index]["imagen"],
                  child: ImagenEnRed(
                    fit: BoxFit.cover,
                    height: 50,
                    width: 50,
                    img: baseUrlSsl + fotos[index]["imagen"],
                    center: true,
                  ),
                ),
              ),
            ),
            staggeredTileBuilder: (int index) =>
                new StaggeredTile.count(2, index.isEven ? 2 : 1),
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
          );
        },
      ),
    );
  }
}
