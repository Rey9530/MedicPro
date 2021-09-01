

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medicpro/src/providers/providers.dart';
import 'package:medicpro/src/widgets/widgets.dart';
import 'package:provider/provider.dart';

class ExpedientesSeach extends SearchDelegate{
  String? get searchFieldLabel => "Buscar...";

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.close),
        onPressed: () => query = "",
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Text("buildResults");
  }
  Widget _emtypData() {
    return Container(
      child: Center(
        child: FaIcon(
          FontAwesomeIcons.search,
          color: Colors.black38,
          size: 130,
        ),
      ),
    );
  }
  
  Widget Buscando() {
    return Container(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _emtypData();
    } 
    final expedientesProvider = Provider.of<ExpedientesProvider>(context);
    expedientesProvider.suggestionByQuery(query);

    return StreamBuilder(
        stream: expedientesProvider.suggestonStream,
        builder: (_, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) return Buscando();
          final listmovies = snapshot.data;
          return (listmovies.length==0) 
          ? Buscando()
          :ListView.builder(
            itemCount: listmovies.length,
            itemBuilder: (_, index) => GestureDetector( onTap: ()=> close(context, null) , child: CardsExpedintes(expdiente: listmovies[index])),
          );
        });
  }

}

