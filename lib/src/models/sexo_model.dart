import 'dart:convert';

class Sexos {
    Sexos({
        this.msj,
        this.codigo,
        required this.data,
    });

    String? msj;
    int? codigo;
    List<Sexo> data;

    factory Sexos.fromJson(String str) => Sexos.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Sexos.fromMap(Map<String, dynamic> json) => Sexos(
        msj: json["msj"],
        codigo: json["codigo"],
        data: List<Sexo>.from( json["data"].map((x) => Sexo.fromMap(x)) ),
    );

    Map<String, dynamic> toMap() => {
        "msj": msj,
        "codigo": codigo,
        "data": List<dynamic>.from(data.map((x) => x.toMap())),
    };
}

class Sexo {
    Sexo({
        required this.idsexo,
        required this.sexo,
        required this.estado,
    });

    String idsexo;
    String sexo;
    String estado;

    factory Sexo.fromJson(String str) => Sexo.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Sexo.fromMap(Map<String, dynamic> json) => Sexo(
        idsexo: json["idsexo"],
        sexo: json["sexo"],
        estado: json["estado"],
    );

    Map<String, dynamic> toMap() => {
        "idsexo": idsexo,
        "sexo": sexo,
        "estado": estado,
    };
}
