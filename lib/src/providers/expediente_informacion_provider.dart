import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicpro/src/models/models.dart';
import 'package:medicpro/src/services/services.dart';
import '../utils/variables.dart' as globalsVariables;

class ExpedienteInformacion extends ChangeNotifier {
  String _baseUrl = globalsVariables.baseUrl;
  List<Consulta> consultas = [];
  final dataUser = new AuthServices();
  bool isLoading = false;

  getAllConsultas(String token_expediente) async {
    if (this.isLoading) return;
    this.consultas = [];
    this.isLoading = true;
    final data = await this
        ._getJsonData('/core/api_rest/get_consultas', token_expediente);

    final popularResponse = Consultas.fromJson(data);
    this.consultas = popularResponse.data;
    this.isLoading = false;
    notifyListeners();
  }

  Future<String> _getJsonData(String endPoint,
      [String token_expediente = ""]) async {
    String token = await dataUser.readToken();
    //print(token);
    final url = Uri.https(_baseUrl, endPoint, {
      'token_expediente': token_expediente,
      'token': token,
    });
    final response = await http.get(url);
    return response.body;
  }
}
