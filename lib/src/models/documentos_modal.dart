import 'dart:convert';

class Documentos {
    Documentos({
        this.msj,
        this.codigo,
        required this.data,
    });

    String? msj;
    int? codigo;
    List<Documento> data;

    factory Documentos.fromJson(String str) => Documentos.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Documentos.fromMap(Map<String, dynamic> json) => Documentos(
        msj: json["msj"],
        codigo: json["codigo"],
        data: List<Documento>.from(json["data"].map((x) => Documento.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "msj": msj,
        "codigo": codigo,
        "data": List<dynamic>.from(data.map((x) => x.toMap())),
    };
}

class Documento {
    Documento({
        this.idTipoDocumento,
        this.tipoDocumento,
        this.estado,
    });

    String? idTipoDocumento;
    String? tipoDocumento;
    String? estado;

    factory Documento.fromJson(String str) => Documento.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Documento.fromMap(Map<String, dynamic> json) => Documento(
        idTipoDocumento: json["idTipoDocumento"],
        tipoDocumento: json["tipoDocumento"],
        estado: json["estado"],
    );

    Map<String, dynamic> toMap() => {
        "idTipoDocumento": idTipoDocumento,
        "tipoDocumento": tipoDocumento,
        "estado": estado,
    };
}
