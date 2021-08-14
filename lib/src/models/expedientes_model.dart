 
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

  factory ExpedientesModel.fromJson(String str) => ExpedientesModel.fromMap(json.decode(str));
 

  factory ExpedientesModel.fromMap(Map<String, dynamic> json) =>
      ExpedientesModel(
        msj: json["msj"],
        codigo: json["codigo"],
        data: List<ExpedienteModel>.from(json["data"].map((x) => ExpedienteModel.fromMap(x))),
      ); 
}

class ExpedienteModel {
  String token_expediente;
  String apellido;
  String nombre;
  String fecha_nacimiento;
  String sexo;
  String? departamento;
  String? direccionTrabajo;
  String? domicilio;
  String? email;
  String? estadoCivil;
  int? idTipoDocumento;
  int? municipio;
  int? numeroDocumento;
  String? telCelular;
  String? telDomicilio;
  String? telOficina;

  ExpedienteModel({
    required this.apellido,
    required this.nombre,
    required this.fecha_nacimiento,
    required this.token_expediente,
    required this.sexo,
    this.departamento,
    this.direccionTrabajo,
    this.domicilio,
    this.email,
    this.estadoCivil,
    this.idTipoDocumento,
    this.municipio,
    this.numeroDocumento,
    this.telCelular,
    this.telDomicilio,
    this.telOficina,
  });

  factory ExpedienteModel.fromJson(String str) => ExpedienteModel.fromMap(json.decode(str));

  //factory Cast.fromMap(Map<String, dynamic> json) => Cast(
  factory ExpedienteModel.fromMap(Map<String, dynamic> json) =>
      ExpedienteModel(
        apellido: json["apellido"],
        departamento: json["departamento"],
        direccionTrabajo: json["direccionTrabajo"],
        domicilio: json["domicilio"],
        email: json["email"],
        estadoCivil: json["estadoCivil"],
        fecha_nacimiento: json["fecha_nacimiento"],
        idTipoDocumento: json["idTipoDocumento"],
        municipio: json["municipio"],
        nombre: json["nombre"],
        numeroDocumento: json["numeroDocumento"],
        sexo: json["sexo"],
        telCelular: json["telCelular"],
        telDomicilio: json["telDomicilio"],
        telOficina: json["telOficina"],
        token_expediente: json["token_expediente"],
      );
}
