import 'dart:io';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:medicpro/src/providers/providers.dart';
import 'package:medicpro/src/themes/theme.dart';
// import 'package:medicpro/src/ui/input_decorations.dart';
import 'package:medicpro/src/widgets/widgets.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
// import 'package:select_form_field/select_form_field.dart';

class ExpedienteEditePage extends StatefulWidget {
  const ExpedienteEditePage();
  @override
  _ExpedienteEditePageState createState() => _ExpedienteEditePageState();
}

class _ExpedienteEditePageState extends State<ExpedienteEditePage> {
  late DateTime dateTime;
  @override
  Widget build(BuildContext context) {
    final providerExpediente = Provider.of<ExpedientesProvider>(context);
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            AppBardCustomerEdit(providerExpediente.expeidnteSeleted!),
            _ImageExpediente(providerExpediente.expeidnteSeleted!.getImg,
                providerExpediente.expeidnteSeleted!.token_expediente),
            Container(
              margin: EdgeInsets.all(10),
              child: Form(
                child: Column(
                  children: [
                    InputsExpediente(
                      label: 'Nombres',
                      placeholder: 'Nombres...',
                      prefix: FontAwesomeIcons.user,
                      validacion: (valor) =>
                          providerExpediente.expeidnteSeleted!.nombre = valor,
                      valor: providerExpediente.expeidnteSeleted!.nombre,
                      keyboardType: TextInputType.name,
                    ),
                    InputsExpediente(
                      label: 'Apellidos',
                      placeholder: 'Apellidos...',
                      prefix: FontAwesomeIcons.user,
                      validacion: (valor) =>
                          providerExpediente.expeidnteSeleted!.apellido = valor,
                      valor: providerExpediente.expeidnteSeleted!.apellido,
                      keyboardType: TextInputType.name,
                    ),
                    Select2(
                      initialValue: providerExpediente.expeidnteSeleted!.sexo,
                      items: providerExpediente.listSexo,
                      label: 'Sexo',
                      placeholder: "",
                      prefix: FontAwesomeIcons.genderless,
                      validacion: (valor) =>
                          providerExpediente.expeidnteSeleted!.sexo = valor,
                    ),
                    InputsExpediente(
                      label: 'F. Nacimiento',
                      placeholder: 'Fecha de Nacimiento',
                      prefix: FontAwesomeIcons.birthdayCake,
                      keyboardType: TextInputType.number,
                      validacion: (valor) => providerExpediente
                          .expeidnteSeleted!
                          .fecha_nacimiento = valor.replaceAll("/", "-"),
                      valor: providerExpediente
                          .expeidnteSeleted!.fecha_nacimiento
                          .replaceAll("-", "/"),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        DataInputFormatter(),
                      ],
                    ),
                    InputsExpediente(
                      label: 'Teléfono Celular',
                      placeholder: 'Digite el Teléfono Celular',
                      keyboardType: TextInputType.phone,
                      prefix: FontAwesomeIcons.phone,
                      validacion: (valor) => providerExpediente
                          .expeidnteSeleted!.telCelular = valor,
                      valor: providerExpediente.expeidnteSeleted!.telCelular
                          .toString(),
                    ),
                    InputsExpediente(
                      label: 'Teléfono Domicilio',
                      placeholder: 'Digite el Teléfono Domicilio',
                      prefix: FontAwesomeIcons.phone,
                      keyboardType: TextInputType.phone,
                      validacion: (valor) => providerExpediente
                          .expeidnteSeleted!.telDomicilio = valor,
                      valor: providerExpediente.expeidnteSeleted!.telDomicilio
                          .toString(),
                    ),
                    InputsExpediente(
                      label: 'Teléfono de Trabajo',
                      placeholder: 'Digite el Teléfono del trabajo',
                      prefix: FontAwesomeIcons.phone,
                      keyboardType: TextInputType.phone,
                      validacion: (valor) => providerExpediente
                          .expeidnteSeleted!.telCelular = valor,
                      valor: providerExpediente.expeidnteSeleted!.telCelular
                          .toString(),
                    ),
                    InputsExpediente(
                      label: 'Correo Electrónico',
                      placeholder: 'Digite el Correo Electrónico',
                      prefix: FontAwesomeIcons.envelope,
                      keyboardType: TextInputType.emailAddress,
                      validacion: (valor) =>
                          providerExpediente.expeidnteSeleted!.email = valor,
                      valor:
                          providerExpediente.expeidnteSeleted!.email.toString(),
                    ),
                    Select2(
                      initialValue:
                          providerExpediente.expeidnteSeleted!.idTipoDocumento,
                      items: providerExpediente.listDocumentos,
                      label: 'Tipo Documento',
                      placeholder: "",
                      prefix: FontAwesomeIcons.genderless,
                      validacion: (valor) => providerExpediente
                          .expeidnteSeleted!.idTipoDocumento = valor,
                    ),
                    InputsExpediente(
                      label: 'Número del Documento',
                      placeholder: 'Digite el Número del Documento',
                      keyboardType: TextInputType.number,
                      prefix: FontAwesomeIcons.passport,
                      validacion: (valor) => providerExpediente
                          .expeidnteSeleted!.numeroDocumento = valor,
                      valor: providerExpediente
                          .expeidnteSeleted!.numeroDocumento
                          .toString(),
                    ),
                    Select2(
                      initialValue:
                          providerExpediente.expeidnteSeleted!.estadoCivil,
                      items: providerExpediente.listeEstadosCivil,
                      label: 'Estao Cvil',
                      placeholder: "",
                      prefix: FontAwesomeIcons.genderless,
                      validacion: (valor) => providerExpediente
                          .expeidnteSeleted!.estadoCivil = valor,
                    ),
                    InputsExpediente(
                      label: 'Domicilio',
                      placeholder: 'Digite la direccion de domicilio',
                      prefix: FontAwesomeIcons.mapMarker,
                      keyboardType: TextInputType.streetAddress,
                      validacion: (valor) => providerExpediente
                          .expeidnteSeleted!.domicilio = valor,
                      valor: providerExpediente.expeidnteSeleted!.domicilio
                          .toString(),
                      maxLines: 3,
                    ),
                    (providerExpediente.isSavin)
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 10),
                              child: Text(
                                  (providerExpediente.expeidnteSeleted!
                                              .token_expediente ==
                                          "0")
                                      ? 'Guardar'
                                      : 'Actualizar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  )),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            color: temaApp.primaryColor,
                            onPressed: providerExpediente.isSavin
                                ? null
                                : () async {  
                                    bool resp = await providerExpediente
                                        .saveOrUpdate(providerExpediente
                                            .expeidnteSeleted!);
                                    if (resp) {
                                      Navigator.of(context).pop();
                                    } else {
                                      showAlertDialog(context, "Excelente",
                                          "Datos Procesados correctamente");
                                    }
                                  },
                          )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}




class _ImageExpediente extends StatelessWidget {
  final String urlImagePerfil;
  final String token_expediente;
  const _ImageExpediente(this.urlImagePerfil, this.token_expediente);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Stack(
        children: [
          Center(
            child: Stack(
              children: [
                Hero(
                  tag: this.token_expediente,
                  child: ImagenPerfil(
                    urlImagePerfil: urlImagePerfil,
                    height: 200,
                    width: 200,
                    radius: 125,
                  ),
                ),
                Positioned(
                  child: GestureDetector(
                    onTap: () => showMaterialModalBottomSheet(
                      expand: false,
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => ModalFit(),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        color: Colors.grey[400],
                        alignment: Alignment.center,
                        width: 50,
                        height: 50,
                        child: FaIcon(
                          FontAwesomeIcons.camera,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  bottom: 5,
                  right: 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
