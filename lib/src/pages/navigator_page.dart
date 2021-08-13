import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medicpro/src/pages/asaber_page.dart';
import 'package:medicpro/src/pages/pages.dart';
import 'package:medicpro/src/themes/theme.dart';

class NavigatorPage extends StatefulWidget {
  @override
  _NavigatorPageState createState() => _NavigatorPageState();
}

class _NavigatorPageState extends State<NavigatorPage> {
  List<Widget> _widgetOptions = <Widget>[
    DiaryPage(),
    PatientsPage(),
    AsaberPage(),
    UserConfigPage(),
  ];
  int _indexSeleccionado = 0;
  // ignore: non_constant_identifier_names
  final double _tamano_icons_menu = 25;

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        //El stack por si se agrega un fondo de pantalla(background)
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(child: _widgetOptions.elementAt(_indexSeleccionado))
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        animationDuration: Duration(milliseconds: 400),
        color: temaApp.primaryColor,
        backgroundColor: temaApp.backgroundColor, //
        buttonBackgroundColor: temaApp.primaryColor,
        height: mediaSize.height * 0.06,
        items: [
          FaIcon(
            FontAwesomeIcons.calendarAlt,
            size: this._tamano_icons_menu,
            color: temaApp.backgroundColor,
          ),
          Icon(
            FontAwesomeIcons.userInjured,
            size: this._tamano_icons_menu,
            color: temaApp.backgroundColor,
          ),
          Icon(
            FontAwesomeIcons.unlock,
            size: this._tamano_icons_menu,
            color: temaApp.backgroundColor,
          ),
          Icon(
            FontAwesomeIcons.userCog,
            size: this._tamano_icons_menu,
            color: temaApp.backgroundColor,
          ),
        ],
        index: _indexSeleccionado,
        onTap: (index) {
          setState(() {
            _indexSeleccionado = index;
          });
        },
      ),
    );
  }
}
