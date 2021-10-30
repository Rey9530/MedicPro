// To parse this JSON data, do
//
//     final events = eventsFromMap(jsonString);

import 'dart:convert';

class Events {
    Events({
        required this.msj,
        required this.codigo,
        required this.data,
        required this.dataTipos,
    });

    String msj;
    int codigo;
    List<Event> data;
    List<TiposConsultas> dataTipos;

    factory Events.fromJson(String str) => Events.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Events.fromMap(Map<String, dynamic> json) => Events(
        msj: json["msj"],
        codigo: json["codigo"],
        data: List<Event>.from(json["data"].map((x) => Event.fromMap(x))),
        dataTipos: List<TiposConsultas>.from(json["dataTipos"].map((x) => TiposConsultas.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "msj": msj,
        "codigo": codigo,
        "data": List<dynamic>.from(data.map((x) => x.toMap())),
        "dataTipos": List<dynamic>.from(dataTipos.map((x) => x.toMap())),
    };
}

class Event {
    Event({
        required this.title,
        required this.backgroundColor,
        required this.tipoconsulta,
        required this.fecha,
        required this.tkCita,
        required this.estado,
        this.observaciones,
    });

    String title;
    String backgroundColor;
    String tipoconsulta;
    DateTime fecha;
    String tkCita;
    String estado;
    String? observaciones;

    factory Event.fromJson(String str) => Event.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Event.fromMap(Map<String, dynamic> json) => Event(
        title:  json["title"],
        backgroundColor:json["backgroundColor"],
        tipoconsulta: json["tipoconsulta"],
        fecha: DateTime.parse(json["fecha"]),
        tkCita: json["tkCita"],
        estado: json["estado"],
        observaciones: json["observaciones"],
    );

    Map<String, dynamic> toMap() => {
        "title": title,
        "backgroundColor":backgroundColor,
        "tipoconsulta": tipoconsulta,
        "fecha": fecha.toIso8601String(),
        "tkCita": tkCita,
        "estado": estado,
        "observaciones": observaciones,
    };
}

class TiposConsultas {
    TiposConsultas({
        required this.tk,
        required this.backgroundColor,
        required this.tipoconsulta, 
    });

    String tk;
    String backgroundColor;
    String tipoconsulta; 

    factory TiposConsultas.fromJson(String str) => TiposConsultas.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory TiposConsultas.fromMap(Map<String, dynamic> json) => TiposConsultas(
        tk:  json["tk"],
        backgroundColor:json["backgroundColor"],
        tipoconsulta: json["tipoconsulta"], 
    );

    Map<String, dynamic> toMap() => {
        "tk": tk,
        "backgroundColor":backgroundColor,
        "tipoconsulta": tipoconsulta, 
    };
}
 
   
  
