import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medicpro/src/providers/providers.dart';
import 'package:medicpro/src/themes/theme.dart';
import 'package:medicpro/src/widgets/widgets.dart';
import 'package:provider/provider.dart';

class EditarImagenPage extends StatelessWidget {
  const EditarImagenPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final providerExpediente = Provider.of<ExpedientesProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBardCustomerEdit(providerExpediente.expeidnteSeleted!),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: ImagenPerfil(
                width: 300,
                height: 300,
                radius: 10,
                urlImagePerfil: providerExpediente.newPictureFile!.path,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Select2(
                initialValue: null,
                items: providerExpediente.listTipeImages,
                label: 'Tipo Imagen',
                placeholder: 'Seleccione...',
                prefix: FontAwesomeIcons.fileAlt,
                validacion: (valor) =>
                    providerExpediente.optionPictureFile = valor,
              ),
            ),
            InputsExpediente(
              label: 'Descripción.',
              placeholder: 'Digite una descripción (Opcional)',
              prefix: FontAwesomeIcons.textHeight,
              keyboardType: TextInputType.streetAddress,
              validacion: (valor) =>
                  providerExpediente.descripPictureFile = valor,
              valor: providerExpediente.expeidnteSeleted!.domicilio.toString(),
              maxLines: 3,
            ),
            Container(
              margin: const EdgeInsets.only(top: 50),
              child: (providerExpediente.isSavin)
                  ? Center(
                      child: Container(
                        margin: EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          color: temaApp.primaryColor,
                        ),
                      ),
                    )
                  : MaterialButton(
                      disabledColor: temaApp.primaryColor,
                      elevation: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 80, vertical: 10),
                        child: Text(
                          'Guardar',
                          style: TextStyle(color: temaApp.backgroundColor),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      color: temaApp.primaryColor,
                      onPressed: providerExpediente.isSavin
                          ? null
                          : () async {
                              final resp =
                                  await providerExpediente.uploadImages();
                              if (resp["data"]) {
                                //showAlertDialog(context, "Excelente", "Datos Procesados correctamente");
                                Navigator.of(context).pop();
                              } else {
                                await showAlertDialog(
                                    context, "Error", "Error:" + resp["msj"]);
                                //Navigator.of(context).pop();
                              }
                            },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
