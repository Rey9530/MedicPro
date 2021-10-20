import 'dart:convert';

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

  Future<List<Consulta>> getAllConsultas(String tokenExpediente) async { 
    this.isLoading = true;
    final data = await this
        ._getJsonData('/core/api_rest/get_consultas', tokenExpediente);

    final popularResponse = Consultas.fromJson(data);
    this.consultas = popularResponse.data;  
    return this.consultas;
  }
  
  Future<List<ExpDocumento>> getDocumentos(String tokenExpediente) async { 
    this.isLoading = true;
    final data = await this
        ._getJsonData('/core/api_rest/get_documentos', tokenExpediente);
    final popularResponse = ExpDocumentos.fromJson(data);
    return  popularResponse.data;  
  }
  
  Future<List<Archivo>> getArchivos(String tokenExpediente) async { 
    this.isLoading = true;
    final data = await this
        ._getJsonData('/core/api_rest/get_archivos', tokenExpediente);
    final response = ExpArchivos.fromJson(data);
    return  response.data;  
  }
  
  Future<List> getIamgesExpedientes(String tokenExpediente) async {  
    final data = await this._getJsonData('/core/api_rest/get_imagenes', tokenExpediente);
    Map<String, dynamic> popularResponse = jsonDecode(data);  
    return popularResponse["data"];
  }

  Future<String> _getJsonData(String endPoint,
      [String tokenExpediente = ""]) async {
    String token = await dataUser.readToken();
    final url = Uri.https(_baseUrl, endPoint, {
      'token_expediente': tokenExpediente,
      'token': token,
    });
    final response = await http.get(url);
    return response.body;
  }
}
