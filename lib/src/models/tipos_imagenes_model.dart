import 'dart:convert';

class TipoImagenes {
    TipoImagenes({
        required this.msj,
        required this.codigo,
        required this.data,
    });

    String msj;
    int codigo;
    List<TipoImagene> data;

    factory TipoImagenes.fromJson(String str) => TipoImagenes.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory TipoImagenes.fromMap(Map<String, dynamic> json) => TipoImagenes(
        msj: json["msj"],
        codigo: json["codigo"],
        data: List<TipoImagene>.from(json["data"].map((x) => TipoImagene.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "msj": msj,
        "codigo": codigo,
        "data": List<dynamic>.from(data.map((x) => x.toMap())),
    };
}

class TipoImagene {
    TipoImagene({
        required this.idtipoimagen,
       required  this.tipoimagen,
    });

    String idtipoimagen;
    String tipoimagen;

    factory TipoImagene.fromJson(String str) => TipoImagene.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory TipoImagene.fromMap(Map<String, dynamic> json) => TipoImagene(
        idtipoimagen: json["idtipoimagen"],
        tipoimagen: json["tipoimagen"],
    );

    Map<String, dynamic> toMap() => {
        "idtipoimagen": idtipoimagen,
        "tipoimagen": tipoimagen,
    };
}
