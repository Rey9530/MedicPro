import 'dart:io';

import 'package:flutter/material.dart'; 
class ImagenPerfil extends StatelessWidget {
  final String urlImagePerfil;
  final double width;
  final double height;
  final double radius;
  const ImagenPerfil({required this.urlImagePerfil, required this.width,required  this.height, required this.radius});


  @override
  Widget build(BuildContext context) { 
    if (urlImagePerfil == "")
      return ClipRRect(
        borderRadius: BorderRadius.circular(125),
        child: Image(image: AssetImage("assets/imgs/no-image.png"),
          fit: BoxFit.cover,
        ),
      );
    if (urlImagePerfil.startsWith("https"))
      return ClipRRect(
        borderRadius: BorderRadius.circular(this.radius),
        child: FadeInImage(
          placeholder: AssetImage("assets/imgs/no-image.png"),
          image: NetworkImage(urlImagePerfil),
          width: this.width,
          height: this.height,
          fit: BoxFit.cover,
        ),
      );
    return ClipRRect(
      borderRadius: BorderRadius.circular(this.radius),
      child: Image.file(
        File(urlImagePerfil),
        fit: BoxFit.cover,
        width: this.width,
        height: this.height,
      ),
    );
  }
}
