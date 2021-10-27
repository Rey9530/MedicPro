
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicpro/src/services/services.dart';
import 'package:medicpro/src/utils/variables.dart';
import 'package:medicpro/src/models/models.dart';
  final dataUser = new AuthServices();

class CitasProvider extends ChangeNotifier{

  String _baseUrl = baseUrl;
  int _page = 0;
  DateTime _mesEnVista = DateTime.now(); 
  bool isLoading = false;
  List<Event> listEvents = [];

  
  CitasProvider() {
    this.getAllCitas(); 
  }

  getAllCitas([bool reload = false]) async {
    if (this.isLoading) return;

    this.isLoading = true;  
    final data = await this._getJsonData('/core/api_rest/get_citas', this._page);
    final reponse = Events.fromJson(data);
    if(reload){ 
      this.listEvents = reponse.data;
      this._page=1;
    }else{
      this.listEvents = [...this.listEvents, ...reponse.data];
      this._page++; 
    }
    this.isLoading = false;
    notifyListeners();
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

}