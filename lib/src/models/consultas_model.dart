import 'dart:convert';

class Consultas {
    Consultas({
        required this.msj,
        required this.codigo,
        required this.data,
    });

    String msj;
    int codigo;
    List<Consulta> data;

    factory Consultas.fromJson(String str) => Consultas.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Consultas.fromMap(Map<String, dynamic> json) => Consultas(
        msj: json["msj"],
        codigo: json["codigo"],
        data: List<Consulta>.from(json["data"].map((x) => Consulta.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "msj": msj,
        "codigo": codigo,
        "data": List<dynamic>.from(data.map((x) => x.toMap())),
    };
}

class Consulta {
    Consulta({
        required this.medico,
        required this.fecha,
        required this.tipoFicha,
        required this.tkConsulta,
        this.isExpander = false,
    });

    String medico;
    String fecha;
    String tipoFicha;
    String tkConsulta;
    bool isExpander;

    factory Consulta.fromJson(String str) => Consulta.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Consulta.fromMap(Map<String, dynamic> json) => Consulta(
        medico: json["medico"],
        fecha: json["fecha"],
        tipoFicha: json["tipo_ficha"],
        tkConsulta: json["tk_consulta"],
    );

    Map<String, dynamic> toMap() => {
        "medico": medico,
        "fecha": fecha,
        "tipo_ficha": tipoFicha,
        "tk_consulta": tkConsulta,
    };
}
 
