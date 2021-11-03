import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicpro/src/services/services.dart';
import 'package:medicpro/src/utils/variables.dart';
import 'package:medicpro/src/models/models.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

final dataUser = new AuthServices();

class CitasProvider extends ChangeNotifier {
  String _baseUrl = baseUrl;
  int _page = 0; 
  DateTime fecha_inicio = DateTime( DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0); 
  DateTime fecha_fin = DateTime( DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0); 
  bool isLoading = false;
  List<Appointment> listEvents = [];
  List<TiposConsultas> dataTipos = []; 

  //displayAppointmentDetails
  //List<String> colorNames,
  CitasProvider() {
    this.isLoading = true;
    this.getAllCitas();
  }

   updateloadin(bool valor) {
    this.isLoading = valor;
    notifyListeners();

   }  
   getAllCitas( [bool reload = false]) async {  
    //notifyListeners();
    final data = await this._getJsonData('/core/api_rest/get_citas', this._page, this.fecha_inicio, this.fecha_fin );
    final reponse = Events.fromJson(data); 
     this.dataTipos = reponse.dataTipos;
   /* if (!reload) {
      this.listEvents = reponse.data;
      this._page = 1;
    } else {
      this.updateloadin= [...this.listEvents, ...reponse.data];
      this.listEvents = [...this.listEvents, ...reponse.data];
      this._page++;
    }*/

    final List<Appointment> appointmentCollection = <Appointment>[];
    reponse.data.map((e) { 
      Color color = HexColor.fromHex("#" +e.backgroundColor );
      appointmentCollection.add(
        Appointment(
          startTime: e.fecha,
          endTime: e.fecha.add(Duration(minutes: 15)),
          color: color,
          startTimeZone: '',
          endTimeZone: '',
          id: e.tkCita,
          recurrenceId: e.tipoconsulta,
          notes: e.tipoconsulta,
          isAllDay: false,
          subject: e.title,
        ),
      );
    }).toList();  
    this.listEvents = appointmentCollection;
     
    this.isLoading= false;
    notifyListeners();
  }

  Future<String> _getJsonData(String endPoint, [int pagina = 0, DateTime? fecha, DateTime? fecha2 ]) async {
    String token = await dataUser.readToken();
    final url = Uri.https(_baseUrl, endPoint, {
      'page': pagina.toString(),
      'token': token,
      'inicio': fecha.toString(),
      'fin': fecha2.toString(),
    });
    final response = await http.get(url);
    return response.body;
  }
}


extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', '')); 
    
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}