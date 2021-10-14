import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medicpro/src/providers/providers.dart';
import 'package:medicpro/src/themes/theme.dart';
import 'package:medicpro/src/widgets/widgets.dart';
import 'package:provider/provider.dart'; 

class ModalFit extends StatefulWidget {
  bool perfil;
  dynamic ruta;
  ModalFit({this.perfil = true, this.ruta = Container});
  @override
  _ModalFitState createState() => _ModalFitState();
}

class _ModalFitState extends State<ModalFit> {
  @override
  Widget build(BuildContext context) {
    final providerExpediente = Provider.of<ExpedientesProvider>(context);
    return Material(
        child: SafeArea(
      top: false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          IconoBottomModal(
            titulo: 'Camara',
            icon: FontAwesomeIcons.camera,
            funcion: () async {
             // Navigator.of(context).pop();
              providerExpediente.updateisSavin(true);
              final picker = new ImagePicker(); //ImagePicker.pickImage
              XFile? pickedFile =
                  await picker.pickImage(source: ImageSource.camera);
              if (pickedFile == null) {
                providerExpediente.updateisSavin(false);
                return false;
              }
              File file = File(pickedFile.path);
              File? otherFile = await _cropImage(file.path);
              if (otherFile == null) {
                providerExpediente.updateisSavin(false);
                return false;
              }
              providerExpediente.updateFoto(otherFile.path, perfil: widget.perfil);
              if (!widget.perfil) {
                Navigator.push(context, CrearRuta(widget.ruta));
              } else {
                Navigator.of(context).pop();
              }
              providerExpediente.updateisSavin(false);
            },
          ),
          IconoBottomModal(
            titulo: 'Galeria',
            icon: FontAwesomeIcons.images,
            funcion: () async {
              //Navigator.of(context).pop();
                providerExpediente.updateisSavin(true);
              final picker = new ImagePicker();
              XFile? pickedFile = await picker.pickImage(
                  source: ImageSource.gallery, imageQuality: 100);
              if (pickedFile == null) {
                providerExpediente.updateisSavin(false);
                return false;
              }
              File file = File(pickedFile.path);
              File? otherFile = await _cropImage(file.path);
              if (otherFile == null) {
                providerExpediente.updateisSavin(false);
                return false;
              }
              providerExpediente.updateFoto(otherFile.path, perfil: widget.perfil);
              if (!widget.perfil) {
                Navigator.push(context, CrearRuta(widget.ruta));
              } else {
                Navigator.of(context).pop();
              }
                providerExpediente.updateisSavin(false);
            },
          ),
        ],
      ),
    ));
  }

  Future<File?> _cropImage(String path) async {
    File? croppedFile = await ImageCropper.cropImage(
        sourcePath: path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cortar',
            toolbarColor: temaApp.primaryColor,
            toolbarWidgetColor: temaApp.backgroundColor,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true),
        iosUiSettings: IOSUiSettings(
          title: 'Cortar 2',
        ));

    if (croppedFile != null) {
      return croppedFile;
    } else {
      return null;
    }
  }
}

class IconoBottomModal extends StatelessWidget {
  final String titulo;
  final IconData icon;
  final Function funcion;
  const IconoBottomModal(
      {Key? key,
      required this.titulo,
      required this.icon,
      required this.funcion})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => this.funcion(),
      child: Container(
        width: 70,
        height: 70,
        margin: EdgeInsets.all(10),
        //color: Colors.red,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(70),
            color: temaApp.primaryColor),
        alignment: Alignment.center,
        child: Column(
          //crossAxisAlignment:CrossAxisAlignment.center ,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              this.icon,
              color: temaApp.backgroundColor,
              size: 30,
            ),
            Text(
              this.titulo,
              style: TextStyle(color: temaApp.backgroundColor),
            )
          ],
        ),
      ),
    );
  }
}
