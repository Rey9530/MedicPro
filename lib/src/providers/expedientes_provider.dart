import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicpro/src/models/expedientes_model.dart';
import 'package:medicpro/src/services/services.dart';

class ExpedientesProvider extends ChangeNotifier {
  String _baseUrl = "medicprohn.app";
  bool isLoading = false;
  int _page = 0;
  List<ExpedienteModel> lisExpdientes = [];
  final dataUser = new AuthServices();

  ExpedientesProvider() {
    this.getAllExpedientes();
  }

  Future<String> _getJsonData(String endPoint, [int pagina = 0]) async {
    String token = await dataUser.readToken();
    final url = Uri.https(_baseUrl, endPoint, {
      'page': pagina.toString(),
      'token': token,
    });
    print("Pagina:" + this._page.toString());
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
}
