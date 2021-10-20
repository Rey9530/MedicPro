import 'dart:convert';

import 'package:medicpro/src/utils/variables.dart';

class ExpDocumentos {
    ExpDocumentos({
        required this.msj,
        required this.codigo,
        required this.data,
    });

    String msj;
    int codigo;
    List<ExpDocumento> data;

    factory ExpDocumentos.fromJson(String str) => ExpDocumentos.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ExpDocumentos.fromMap(Map<String, dynamic> json) => ExpDocumentos(
        msj: json["msj"],
        codigo: json["codigo"],
        data: List<ExpDocumento>.from(json["data"].map((x) => ExpDocumento.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "msj": msj,
        "codigo": codigo,
        "data": List<dynamic>.from(data.map((x) => x.toMap())),
    };
}

class ExpDocumento {
    ExpDocumento({
        required this.medico,
        required this.documento,
        required this.tipoplantilla,
        required this.fecha,
        required this.tkDocumento,
    });

    String medico;
    String documento;
    String tipoplantilla;
    String fecha;
    String tkDocumento;

    factory ExpDocumento.fromJson(String str) => ExpDocumento.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ExpDocumento.fromMap(Map<String, dynamic> json) => ExpDocumento(
        medico: json["medico"],
        documento: json["documento"],
        tipoplantilla: json["tipoplantilla"],
        fecha: json["fecha"],
        tkDocumento: json["tk_documento"],
    );

    Map<String, dynamic> toMap() => {
        "medico": medico,
        "documento": documento,
        "tipoplantilla": tipoplantilla,
        "fecha": fecha,
        "tk_documento": tkDocumento,
    };

    getUrl(){
      return baseUrlSsl +"clinica/documentos/imprimir?select=1&id=" +this.tkDocumento +"&carta=true";
    }
}
