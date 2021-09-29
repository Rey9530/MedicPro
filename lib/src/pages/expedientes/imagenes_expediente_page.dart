import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:medicpro/src/pages/expedientes/expedientes_imagenes_datelle_page.dart';
import 'package:medicpro/src/providers/providers.dart';
import 'package:medicpro/src/themes/theme.dart';
import 'package:medicpro/src/utils/variables.dart';
import 'package:medicpro/src/widgets/widgets.dart';
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
      child: Scaffold(
        body: Stack(
          children: [
            FutureImages(
                token_expediente:
                    providerExpediente.expeidnteSeleted!.token_expediente),
            AppBardCustomerEdit(providerExpediente.expeidnteSeleted!),
          ],
        ),
      ),
    );
  }
}

class FutureImages extends StatelessWidget {
  final String token_expediente;
  const FutureImages({
    required this.token_expediente,
  });

  @override
  Widget build(BuildContext context) {
    final consultasList =
        Provider.of<ExpedienteInformacion>(context, listen: false);
    return Container(
      margin: const EdgeInsets.only(top: 50),
      child: FutureBuilder(
        future: consultasList.getIamgesExpedientes(this.token_expediente),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: temaApp.primaryColor,
              ),
            );
          }
          final List fotos = snapshot.data!;
          return new StaggeredGridView.countBuilder(
            crossAxisCount: 4,
            itemCount: fotos.length,
            itemBuilder: (BuildContext context, int index) => GestureDetector(
              onTap: () {
                Navigator.push(
                    context, _CrearRuta(ImagenesDetallePage(index, fotos)));
              },
              child: new Container(
                color: temaApp.primaryColor,
                child: Hero(
                  tag: fotos[index]["imagen"],
                  child: FadeInImage(
                    placeholder: AssetImage("assets/imgs/no-image.png"),
                    image: NetworkImage(
                      baseUrlSsl + fotos[index]["imagen"],
                    ),
                    fit: BoxFit.cover,
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

  Route _CrearRuta(pagina) {
    return PageRouteBuilder(
      pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) =>
          pagina,
      transitionDuration: Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curveAniumation =
            CurvedAnimation(parent: animation, curve: Curves.easeIn);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(curveAniumation),
          child: FadeTransition(
            opacity:
                Tween<double>(begin: 0.0, end: 1.0).animate(curveAniumation),
            child: child,
          ),
        );
      },
    );
  }
}
