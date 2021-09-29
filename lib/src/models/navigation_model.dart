import 'package:flutter/material.dart';

class NavegacionModel extends ChangeNotifier {
  int _pagina = 0;

  PageController _pageControler = new PageController();

  int get paginaActual => this._pagina;
  set paginaActual(int pagina) {
    this._pagina = pagina;
    _pageControler.animateToPage(pagina,
        duration: Duration(milliseconds: 250), curve: Curves.easeOut);
    notifyListeners();
  }

  PageController get pageControler => this._pageControler;
}