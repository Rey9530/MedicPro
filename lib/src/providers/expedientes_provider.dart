import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicpro/src/helpers/debouncer.dart';
import 'package:medicpro/src/models/expedientes_model.dart';
import 'package:medicpro/src/services/services.dart';

class ExpedientesProvider extends ChangeNotifier {
  String _baseUrl = "medicprohn.app";
  bool isLoading = false;
  int _page = 0;
  List<ExpedienteModel> lisExpdientes = [];
  final dataUser = new AuthServices();

  final debouncer = Debouncer(duration: Duration(milliseconds: 500));

  final StreamController<List<ExpedienteModel>> _suggestionStreamControler =
      new StreamController.broadcast();
  Stream<List<ExpedienteModel>> get suggestonStream =>
      this._suggestionStreamControler.stream;

  ExpedientesProvider() {
    this.getAllExpedientes();
  }

  Future<String> _getJsonData(String endPoint, [int pagina = 0]) async {
    String token = await dataUser.readToken();
    final url = Uri.https(_baseUrl, endPoint, {
      'page': pagina.toString(),
      'token': token,
    }); 
    final response = await http.get(url);
    return response.body;
  }

  getAllExpedientes() async {
    if (this.isLoading) return;
    this.isLoading = true;
    final data = await this
        ._getJsonData('/core/api_rest/get_all_expedientes', this._page);
    final popularResponse = ExpedientesModel.fromJson(data);
    this.lisExpdientes = [...this.lisExpdientes, ...popularResponse.data];
    this._page++;
    this.isLoading = false;
    notifyListeners();
  }

  Future<List<ExpedienteModel>> searchExpediente(String query) async {
     
    String token = await dataUser.readToken();
    final url = Uri.https(_baseUrl, '/core/api_rest/get_search_expedientes', {
      'query': query,
      'token': token,
    }); 
    final response = await http.get(url); 
    final popularResponse = ExpedientesModel.fromJson(response.body);
    return popularResponse.data;
  }

  void suggestionByQuery(String searchTerm) {
    debouncer.value = '';
    debouncer.onValue = (query) async {
      final result = await this.searchExpediente(query);
      this._suggestionStreamControler.add(result);
    };
    final timer = Timer.periodic(Duration(milliseconds: 300), (_) {
      debouncer.value = searchTerm;
    });
    Future.delayed(Duration(milliseconds: 301)).then((_) => timer.cancel());
  }
}
