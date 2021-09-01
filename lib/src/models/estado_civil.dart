import 'dart:convert';

class EstadosCivil {
    EstadosCivil({
        this.msj,
        this.codigo,
        required this.data,
    });

    String? msj;
    int? codigo;
    List<EstadoCivil> data;

    factory EstadosCivil.fromJson(String str) => EstadosCivil.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory EstadosCivil.fromMap(Map<String, dynamic> json) => EstadosCivil(
        msj: json["msj"],
        codigo: json["codigo"],
        data: List<EstadoCivil>.from(json["data"].map((x) => EstadoCivil.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "msj": msj,
        "codigo": codigo,
        "data": List<dynamic>.from(data.map((x) => x.toMap())),
    };
}

class EstadoCivil {

    EstadoCivil({
        required this.id,
        required this.value,
    });

    String id;
    String value;

    factory EstadoCivil.fromJson(String str) => EstadoCivil.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory EstadoCivil.fromMap(Map<String, dynamic> json) => EstadoCivil(
        id: json["id"],
        value: json["value"],
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "value": value,
    };
}
