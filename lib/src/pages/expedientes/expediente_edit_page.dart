import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medicpro/src/models/expedientes_model.dart';
import 'package:medicpro/src/providers/providers.dart';
import 'package:medicpro/src/themes/theme.dart';
import 'package:medicpro/src/ui/input_decorations.dart';
import 'package:provider/provider.dart';
import 'package:select_form_field/select_form_field.dart';

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
        body: SafeArea(
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              AppBardCustomerEdit(providerExpediente.expeidnteSeleted!),
              _ImageExpediente(providerExpediente.expeidnteSeleted!.getImg),
              Container(
                margin: EdgeInsets.all(10),
                child: Form(
                  child: Column(
                    children: [
                      _InputsExpediente(
                        label: 'Nombres',
                        placeholder: 'Nombres...',
                        prefix: FontAwesomeIcons.user,
                        validacion: (valor) =>
                            providerExpediente.expeidnteSeleted!.nombre = valor,
                        valor: providerExpediente.expeidnteSeleted!.nombre,
                        keyboardType: TextInputType.name,
                      ),
                      _InputsExpediente(
                        label: 'Apellidos',
                        placeholder: 'Apellidos...',
                        prefix: FontAwesomeIcons.user,
                        validacion: (valor) => providerExpediente
                            .expeidnteSeleted!.apellido = valor,
                        valor: providerExpediente.expeidnteSeleted!.apellido,
                        keyboardType: TextInputType.name,
                      ),
                      _Select2(
                        initialValue: providerExpediente.expeidnteSeleted!.sexo,
                        items: providerExpediente.listSexo,
                        label: 'Sexo',
                        placeholder: "",
                        prefix: FontAwesomeIcons.genderless,
                        validacion: (valor) =>
                            providerExpediente.expeidnteSeleted!.sexo = valor,
                      ),
                      _InputsExpediente(
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
                      _InputsExpediente(
                        label: 'Teléfono Celular',
                        placeholder: 'Digite el Teléfono Celular',
                        keyboardType: TextInputType.phone,
                        prefix: FontAwesomeIcons.phone,
                        validacion: (valor) => providerExpediente
                            .expeidnteSeleted!.telCelular = valor,
                        valor: providerExpediente.expeidnteSeleted!.telCelular
                            .toString(),
                      ),
                      _InputsExpediente(
                        label: 'Teléfono Domicilio',
                        placeholder: 'Digite el Teléfono Domicilio',
                        prefix: FontAwesomeIcons.phone,
                        keyboardType: TextInputType.phone,
                        validacion: (valor) => providerExpediente
                            .expeidnteSeleted!.telDomicilio = valor,
                        valor: providerExpediente.expeidnteSeleted!.telDomicilio
                            .toString(),
                      ),
                      _InputsExpediente(
                        label: 'Teléfono de Trabajo',
                        placeholder: 'Digite el Teléfono del trabajo',
                        prefix: FontAwesomeIcons.phone,
                        keyboardType: TextInputType.phone,
                        validacion: (valor) => providerExpediente
                            .expeidnteSeleted!.telCelular = valor,
                        valor: providerExpediente.expeidnteSeleted!.telCelular
                            .toString(),
                      ),
                      _InputsExpediente(
                        label: 'Correo Electrónico',
                        placeholder: 'Digite el Correo Electrónico',
                        prefix: FontAwesomeIcons.envelope,
                        keyboardType: TextInputType.emailAddress,
                        validacion: (valor) =>
                            providerExpediente.expeidnteSeleted!.email = valor,
                        valor: providerExpediente.expeidnteSeleted!.email
                            .toString(),
                      ),
                      _Select2(
                        initialValue: providerExpediente
                            .expeidnteSeleted!.idTipoDocumento,
                        items: providerExpediente.listDocumentos,
                        label: 'Tipo Documento',
                        placeholder: "",
                        prefix: FontAwesomeIcons.genderless,
                        validacion: (valor) => providerExpediente
                            .expeidnteSeleted!.idTipoDocumento = valor,
                      ),
                      _InputsExpediente(
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
                      _Select2(
                        initialValue:
                            providerExpediente.expeidnteSeleted!.estadoCivil,
                        items: providerExpediente.listeEstadosCivil,
                        label: 'Estao Cvil',
                        placeholder: "",
                        prefix: FontAwesomeIcons.genderless,
                        validacion: (valor) => providerExpediente
                            .expeidnteSeleted!.estadoCivil = valor,
                      ),
                      _InputsExpediente(
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
                                child: Text('Actualizar',
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
                                      //final String? imgUrl = await producService.uploadImage();
                                      //if (imgUrl != null) pruducForm.produc.picture = imgUrl;
                                      await providerExpediente.saveOrUpdate(
                                          providerExpediente.expeidnteSeleted!);
                                    },
                            )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class AppBardCustomerEdit extends StatelessWidget {
  final ExpedienteModel expedinte;
  const AppBardCustomerEdit(this.expedinte);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: temaApp.primaryColor,
      padding: EdgeInsets.symmetric(horizontal: 15),
      width: double.infinity,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 30,
              height: 30,
              child: FaIcon(
                FontAwesomeIcons.chevronLeft,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Text(
              expedinte.nombre + "" + expedinte.apellido,
              style: TextStyle(
                  color: temaApp.backgroundColor, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }
}

class _Select2 extends StatelessWidget {
  final dynamic initialValue;
  final List<Map<String, dynamic>> items;
  final String placeholder;
  final String label;
  final IconData prefix;
  final Function validacion;

  const _Select2({
    required this.initialValue,
    required this.placeholder,
    required this.label,
    required this.validacion,
    required this.items,
    required this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: SelectFormField(
        style: TextStyle(
          color: temaApp.primaryColor,
        ),
        cursorColor: temaApp.primaryColor,
        type: SelectFormFieldType.dropdown, // or can be dialog
        initialValue: this.initialValue,
        icon: FaIcon(
          this.prefix,
          color: temaApp.primaryColor,
        ),
        labelText: this.label,
        items: this.items,
        onChanged: ((value) {
          this.validacion(value);
        }),
        onSaved: (val) => this.validacion,
      ),
    );
  }
}

class _InputsExpediente extends StatelessWidget {
  final String valor;
  final String placeholder;
  final String label;
  final TextInputType keyboardType;
  final IconData prefix;
  final Function validacion;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;

  const _InputsExpediente({
    required this.valor,
    required this.placeholder,
    required this.label,
    required this.prefix,
    required this.validacion,
    required this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        maxLines: this.maxLines,
        initialValue: valor,
        autocorrect: false,
        keyboardType: keyboardType,
        decoration: InputDecorations.authInputDecoration(
          hintText: this.placeholder,
          labelText: this.label,
          prefixIcon: this.prefix,
        ),
        inputFormatters: this.inputFormatters,
        validator: ((value) {
          this.validacion(value);
        }),
        onChanged: ((value) {
          this.validacion(value);
        }),
      ),
    );
  }
}

class _ImageExpediente extends StatelessWidget {
  final String urlImagePerfil;
  const _ImageExpediente(this.urlImagePerfil);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Stack(
        children: [
          Center(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(125),
                  child: FadeInImage(
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    placeholder: AssetImage("assets/imgs/no-image.png"),
                    image: NetworkImage(urlImagePerfil),
                  ),
                ),
                Positioned(
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
