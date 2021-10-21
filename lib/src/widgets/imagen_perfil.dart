import 'dart:io';

import 'package:flutter/material.dart';
import 'package:medicpro/src/providers/providers.dart';
import 'package:provider/provider.dart';

class ImagenPerfil extends StatelessWidget {
  final String urlImagePerfil;
  final double width;
  final double height;
  final double radius;
  const ImagenPerfil({required this.urlImagePerfil, required this.width,required  this.height, required this.radius});


  @override
  Widget build(BuildContext context) {
    final providerExpediente = Provider.of<ExpedientesProvider>(context);
     dynamic url = providerExpediente.expeidnteSeleted!.getImg;
    if (url == null)
      return ClipRRect(
        borderRadius: BorderRadius.circular(125),
        child: Image(image: AssetImage("assets/imgs/no-image.png"),
          fit: BoxFit.cover,
        ),
      );
    if (url.startsWith("https"))
      return ClipRRect(
        borderRadius: BorderRadius.circular(this.radius),
        child: FadeInImage(
          placeholder: AssetImage("assets/imgs/no-image.png"),
          image: NetworkImage(url),
          width: this.width,
          height: this.height,
          fit: BoxFit.cover,
        ),
      );
    return ClipRRect(
      borderRadius: BorderRadius.circular(this.radius),
      child: Image.file(
        File(url),
        fit: BoxFit.cover,
        width: this.width,
        height: this.height,
      ),
    );
  }
}
