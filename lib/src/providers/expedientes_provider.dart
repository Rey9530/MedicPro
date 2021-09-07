import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicpro/src/helpers/debouncer.dart';
import 'package:medicpro/src/models/models.dart';
import 'package:medicpro/src/services/services.dart';
import 'package:medicpro/src/themes/theme.dart';

class ExpedientesProvider extends ChangeNotifier {
  String _baseUrl = "medicprohn.app";
  bool isLoading = false;
  bool isSavin = false;
  int _page = 0;
  List<ExpedienteModel> lisExpdientes = [];
  ExpedienteModel? expeidnteSeleted;
  File? newPictureFile;
  List<Map<String, dynamic>> listSexo = [];
  List<Map<String, dynamic>> listDocumentos = [];
  List<Map<String, dynamic>> listeEstadosCivil = [];
  final dataUser = new AuthServices();

  final debouncer = Debouncer(duration: Duration(milliseconds: 500));

  final StreamController<List<ExpedienteModel>> _suggestionStreamControler =
      new StreamController.broadcast();
  Stream<List<ExpedienteModel>> get suggestonStream =>
      this._suggestionStreamControler.stream;

  ExpedientesProvider() {
    this.getAllExpedientes();
    this.getSexo();
    this.getDocumentos();
    this.getListeEstadosCivil();
  }

  updateFoto(String imagen) {
    this.expeidnteSeleted!.foto = imagen;
    this.newPictureFile = File.fromUri(Uri(path: imagen));
    notifyListeners();
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

  Future<bool> saveOrUpdate(ExpedienteModel expdiente) async {
    this.isSavin = true;
    notifyListeners();
    bool resp = false;
    if (expdiente.token_expediente == "0") {
      // Guardar Producto
      await saveExpediente(expdiente);
      NotificationsServices.showSnackbar("Datos Guardados");
      resp = true;
    } else {
      // Actualizar Producto
      await updateExpediente(expdiente);
      NotificationsServices.showSnackbar("Datos Actualizados");
      resp = false;
    }
    this.isSavin = false;
    notifyListeners();
    return resp;
  }

  Future<String?> uploadImage(String token) async {
    if (this.newPictureFile == null) return null;

    final url =
        Uri.parse("https://" + _baseUrl + "/core/api_rest/upload_image");
    final imageUpload = http.MultipartRequest('POST', url)
      ..fields["token_expediente"] = token
      ..fields["token"] = await dataUser.readToken();

    final file =
        await http.MultipartFile.fromPath('file', newPictureFile!.path);
    imageUpload.files.add(file);
    newPictureFile = null;
    final streamedResponse = await imageUpload.send();
    final resp = await http.Response.fromStream(streamedResponse);
    final decodeData = json.decode(resp.body);
    return decodeData["data"];
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

  Future<String?> updateExpediente(ExpedienteModel expdiente) async {
    String token = await dataUser.readToken();
    final url = Uri.https(_baseUrl, '/core/api_rest/update_expedientes');
    expdiente.token = token;
    await http.post(url, body: expdiente.toSend());
    final index = this.lisExpdientes.indexWhere(
        (element) => element.token_expediente == expdiente.token_expediente);
    if (this.newPictureFile != null) {
      final String? img = await uploadImage(expdiente.token_expediente);
      expdiente.foto = img!;
    }
    this.lisExpdientes[index] = expdiente;
    return expdiente.token_expediente;
  }

  Future<String?> saveExpediente(ExpedienteModel expdiente) async {
    String token = await dataUser.readToken();
    final url = Uri.https(_baseUrl, '/core/api_rest/save_expedientes');
    expdiente.token = token;
    final resp = await http.post(url, body: expdiente.toSend());
    final dataResponse = json.decode(resp.body);
    expdiente.token_expediente = dataResponse["data"];
    this.lisExpdientes.add(expdiente);

    if (this.newPictureFile != null) {
      final String? img = await uploadImage(expdiente.token_expediente);
      expdiente.foto = img!;
    }
    return expdiente.token_expediente;
  }

  getSexo() async {
    final data = await this._getJsonData('/core/api_rest/get_sexo');
    final popularResponse = Sexos.fromJson(data);
    popularResponse.data.forEach((element) {
      final Map<String, dynamic> variebla = {
        'value': element.idsexo,
        'label': element.sexo,
        'textStyle': TextStyle(color: temaApp.primaryColor),
      };
      this.listSexo.add(variebla);
    });
    //notifyListeners();
  }

  getDocumentos() async {
    final data =
        await this._getJsonData('/core/api_rest/get_all_tipo_documentos');
    final popularResponse = Documentos.fromJson(data);
    popularResponse.data.forEach((element) {
      final Map<String, dynamic> variebla = {
        'value': element.idTipoDocumento,
        'label': element.tipoDocumento,
        'textStyle': TextStyle(color: temaApp.primaryColor),
      };
      this.listDocumentos.add(variebla);
    });
    //notifyListeners();
  }

  getListeEstadosCivil() async {
    final data = await this._getJsonData('/core/api_rest/get_estado_civil');
    final popularResponse = EstadosCivil.fromJson(data);
    popularResponse.data.forEach((element) {
      final Map<String, dynamic> variebla = {
        'value': element.id,
        'label': element.value,
        'textStyle': TextStyle(color: temaApp.primaryColor),
      };
      this.listeEstadosCivil.add(variebla);
    });
    print(this.listeEstadosCivil[0]);
    //notifyListeners();
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
