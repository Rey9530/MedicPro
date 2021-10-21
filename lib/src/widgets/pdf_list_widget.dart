import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medicpro/src/pages/pages.dart';
import 'package:medicpro/src/widgets/widgets.dart';

class ViewListPdf extends StatelessWidget {
  const ViewListPdf({
    Key? key,
    required this.url,
    required this.title,
  }) : super(key: key);

  final String url;
  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (this.url != "N/A") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PDFViewer(url, this.title),
            ),
          );
        }else{
          showAlertDialog(context, "Ooops","Ha ocurrido un error favor verificarlo con soporte técnico");
        }
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        child: Material(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          elevation: 5,
          child: ListTile(
            leading: FaIcon(FontAwesomeIcons.filePdf),
            title: Text(this.title),
          ),
        ),
      ),
    );
  }
}
