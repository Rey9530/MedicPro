import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:share/share.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medicpro/src/themes/theme.dart'; 

class PDFViewer extends StatelessWidget {
  final String urlBase;
  final String title;
  const PDFViewer(this.urlBase, this.title);
  @override
  Widget build(BuildContext context) {
    String url = "";
    return Scaffold(
      appBar: AppBar(
        backgroundColor: temaApp.primaryColor,
        title: Text(title),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.of(context).pop();
 
              File picture =File(url);  
              String dir = path.dirname(picture.path);
              String newPath = path.join(dir, this.title+'.pdf'); 
              picture.renameSync(newPath); 

              Share.shareFiles([newPath], text: this.title);
            },
            child: FaIcon(
              FontAwesomeIcons.shareAlt,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: const PDF().cachedFromUrl(
        urlBase ,
        placeholder: (progress) {
          return Center(child: Text('$progress %'));
        },
        errorWidget: (dynamic error) => Center(child: Text(error.toString())),
        whenDone: (pdf) { 
          url = pdf;
        },
      ),
    );
  }
}
