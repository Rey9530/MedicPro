// To parse this JSON data, do
//
//     final expArchivos = expArchivosFromMap(jsonString);

import 'dart:convert';

import 'package:medicpro/src/utils/variables.dart';

class ExpArchivos {
    ExpArchivos({
        required this.msj,
        required this.codigo,
        required this.data,
    });

    String msj;
    int codigo;
    List<Archivo> data;

    factory ExpArchivos.fromJson(String str) => ExpArchivos.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ExpArchivos.fromMap(Map<String, dynamic> json) => ExpArchivos(
        msj: json["msj"],
        codigo: json["codigo"],
        data: List<Archivo>.from(json["data"].map((x) => Archivo.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "msj": msj,
        "codigo": codigo,
        "data": List<dynamic>.from(data.map((x) => x.toMap())),
    };
}

class Archivo {
    Archivo({
        required this.medico,
        required this.archivo,
        required this.fecha,
        this.descripcion,
        required this.ruta,
        required this.tipo,
        required this.tkDocumento,
    });

    String medico;
    String archivo;
    String fecha;
    String? descripcion;
    String ruta;
    String tipo;
    String tkDocumento;

    factory Archivo.fromJson(String str) => Archivo.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Archivo.fromMap(Map<String, dynamic> json) => Archivo(
        medico: json["medico"],
        archivo: json["archivo"],
        fecha: json["fecha"],
        descripcion: json["descripcion"],
        ruta: json["ruta"],
        tipo: json["tipo"],
        tkDocumento: json["tk_documento"],
    );

    Map<String, dynamic> toMap() => {
        "medico": medico,
        "archivo": archivo,
        "fecha": fecha,
        "descripcion": descripcion,
        "ruta": ruta,
        "tipo": tipo,
        "tk_documento": tkDocumento,
    };

     getUrl(){
      return baseUrlSsl +ruta;
    }
}
