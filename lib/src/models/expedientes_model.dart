// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

class ExpedientesModel {
  ExpedientesModel({
    required this.msj,
    required this.codigo,
    required this.data,
  });

  String msj;
  int codigo;
  List<ExpedienteModel> data;

  factory ExpedientesModel.fromJson(String str) =>
      ExpedientesModel.fromMap(json.decode(str));

  factory ExpedientesModel.fromMap(Map<String, dynamic> json) =>
      ExpedientesModel(
        msj: json["msj"],
        codigo: json["codigo"],
        data: List<ExpedienteModel>.from(
            json["data"].map((x) => ExpedienteModel.fromMap(x))),
      );
}

class ExpedienteModel {
  String token_expediente;
  String apellido;
  String nombre;
  String foto;
  String fecha_nacimiento;
  String sexo;
  String? pais; //por el momento no
  String? departamento; //por el momento no
  String? idTipoDocumento;
  String? municipio; //por el momento no
  String? direccionTrabajo; //-----
  String? domicilio; //-----
  String? email;
  String? estadoCivil;
  String? numeroDocumento;
  String? telCelular;
  String? telDomicilio;
  String? telOficina;
  String? token;

  ExpedienteModel({
    required this.apellido,
    required this.nombre,
    required this.foto,
    required this.fecha_nacimiento,
    required this.token_expediente,
    required this.sexo,
    this.pais="",
    this.departamento="",
    this.direccionTrabajo="",
    this.domicilio="",
    this.email="",
    this.estadoCivil="",
    this.idTipoDocumento="",
    this.municipio="",
    this.numeroDocumento="",
    this.telCelular="",
    this.telDomicilio="",
    this.telOficina="",
    this.token="",
  });
  get getImg {
    if ( this.foto.startsWith("assets")) { 
      return "https://medicprohn.app/core/$foto";
    } else {
      return this.foto;
    }
  }

  factory ExpedienteModel.fromJson(String str) =>
      ExpedienteModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());
  Map<String, dynamic> toMap() => {
        "apellido": this.apellido,
        "nombre": this.nombre,
        "foto": this.foto,
        "fecha_nacimiento": this.fecha_nacimiento,
        "token_expediente": this.token_expediente,
        "sexo": this.sexo,
        "pais": this.pais,
        "departamento": this.departamento,
        "direccionTrabajo": this.direccionTrabajo,
        "domicilio": this.domicilio,
        "email": this.email,
        "estadoCivil": this.estadoCivil,
        "idTipoDocumento": this.idTipoDocumento,
        "municipio": this.municipio,
        "numeroDocumento": this.numeroDocumento,
        "telCelular": this.telCelular,
        "telDomicilio": this.telDomicilio,
        "telOficina": this.telOficina,
        "token": this.token,
      };

  Map<String, String> toSend() => {
        "apellido": this.apellido,
        "nombre": this.nombre,
        "foto": this.foto,
        "fecha_nacimiento": this.fecha_nacimiento,
        "token_expediente": this.token_expediente,
        "sexo": this.sexo,
        "pais": this.pais.toString(),
        "departamento": this.departamento.toString(),
        "direccionTrabajo": this.direccionTrabajo.toString(),
        "domicilio": this.domicilio.toString(),
        "email": this.email.toString(),
        "estadoCivil": this.estadoCivil.toString(),
        "idTipoDocumento": this.idTipoDocumento.toString(),
        "municipio": this.municipio.toString(),
        "numeroDocumento": this.numeroDocumento.toString(),
        "telCelular": this.telCelular.toString(),
        "telDomicilio": this.telDomicilio.toString(),
        "telOficina": this.telOficina.toString(),
        "token": this.token.toString(),
      };
  //factory Cast.fromMap(Map<String, dynamic> json) => Cast(
  factory ExpedienteModel.fromMap(Map<String, dynamic> json) => ExpedienteModel(
        nombre: json["nombre"],
        apellido: json["apellido"],
        foto: json["foto"],
        departamento: json["departamento"],
        direccionTrabajo: json["direccionTrabajo"],
        domicilio: json["domicilio"],
        email: json["email"],
        pais: json["pais"],
        estadoCivil: json["estadoCivil"],
        fecha_nacimiento: json["fecha_nacimiento"],
        idTipoDocumento: json["idTipoDocumento"],
        municipio: json["municipio"],
        numeroDocumento: json["numeroDocumento"],
        sexo: json["sexo"],
        telCelular: json["telCelular"],
        telDomicilio: json["telDomicilio"],
        telOficina: json["telOficina"],
        token_expediente: json["token_expediente"],
        token: json["token"],
      );

  ExpedienteModel copy() => ExpedienteModel(
        apellido: this.apellido,
        nombre: this.nombre,
        foto: this.foto,
        fecha_nacimiento: this.fecha_nacimiento,
        token_expediente: this.token_expediente,
        sexo: this.sexo,
        pais: this.pais,
        departamento: this.departamento,
        direccionTrabajo: this.direccionTrabajo,
        domicilio: this.domicilio,
        email: this.email,
        estadoCivil: this.estadoCivil,
        idTipoDocumento: this.idTipoDocumento,
        municipio: this.municipio,
        numeroDocumento: this.numeroDocumento,
        telCelular: this.telCelular,
        telDomicilio: this.telDomicilio,
        telOficina: this.telOficina,
        token: this.token,
      );
}
