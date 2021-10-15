import 'package:flutter/material.dart';
import 'package:medicpro/src/themes/theme.dart';

class ImagenEnRed extends StatelessWidget {
  final double width;
  final double height;
  final BoxFit fit;
  final String img;
  final bool center;

  const ImagenEnRed({
    required this.width,
    required this.height,
    required this.fit,
    required this.img,
    this.center=false,
  });

  @override
  Widget build(BuildContext context) {
    return new Image.network(
      img,
      width: this.width,
      height: this.height,
      fit: this.fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        if (this.center) {
          return Center(
            child: _LocalLoading(loadingProgress),
          );
        } else {
          return _LocalLoading(loadingProgress);
        }
      },
      errorBuilder: (context, exception, stackTrace) {
        return Image.asset("assets/imgs/no-image.png");
      },
    );
  }
}

class _LocalLoading extends StatelessWidget {
  final loadingProgress;
  const _LocalLoading(this.loadingProgress);

  @override
  Widget build(BuildContext context) {
    return new CircularProgressIndicator(
      value: loadingProgress.expectedTotalBytes != null
          ? loadingProgress.cumulativeBytesLoaded /
              loadingProgress.expectedTotalBytes!
          : null,
      color: temaApp.primaryColor,
    );
  }
}
