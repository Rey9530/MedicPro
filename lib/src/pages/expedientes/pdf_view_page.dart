import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:medicpro/src/themes/theme.dart';
import 'package:medicpro/src/utils/variables.dart';

class PDFViewer extends StatelessWidget { 
 final String tk;
 final String title;
  const PDFViewer(this.tk, this.title);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: temaApp.primaryColor,
        title: Text(title),
      ),
      body: const PDF().fromUrl(
        baseUrlSsl+"clinica/documentos/imprimir?select=1&id="+tk+"&carta=true",
        placeholder: (progress) {
          print(progress);
          return Center(child: Text('$progress %'));
        },
        errorWidget: (dynamic error) => Center(child: Text(error.toString())),
      ),
    );
  }
}
 