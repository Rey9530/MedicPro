// ignore_for_file: non_constant_identifier_names, unnecessary_null_comparison

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

  static List<ExpedienteModel> fromJsonList(List list) {
    return list.map((item) => ExpedienteModel.fromMap(item)).toList();
  }
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
    this.pais = "",
    this.departamento = "",
    this.direccionTrabajo = "",
    this.domicilio = "",
    this.email = "",
    this.estadoCivil = "",
    this.idTipoDocumento = "",
    this.municipio = "",
    this.numeroDocumento = "",
    this.telCelular = "",
    this.telDomicilio = "",
    this.telOficina = "",
    this.token = "",
  });
  get getImg {
    if (this.foto.startsWith("assets")) {
      return "https://medicprohn.app/core/$foto";
    } else {
      return this.foto;
    }
  }
  
  String getUrlImg() {
    if (this.foto.startsWith("assets")) {
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



class UserModel {
  final String id;
  final DateTime createdAt;
  final String name;
  final String avatar;
  final String celular;

  UserModel({ required this.celular, required this.id,required  this.createdAt,required  this.name,required  this.avatar});

  factory UserModel.fromJson(Map<String, dynamic> json) {  
    return UserModel(
      id: json["id"],
      createdAt: json["createdAt"],
      name: json["name"],
      avatar: json["avatar"],
      celular: json["celular"],
    );
  }

  static List<UserModel> fromJsonList(List list) { 
    return list.map((item) => UserModel.fromJson(item)).toList();
  }

  ///this method will prevent the override of toString
  String userAsString() {
    return '#${this.id} ${this.name}';
  }

  ///this method will prevent the override of toString
  bool userFilterByCreationDate(String filter) {
    return this.createdAt.toString().contains(filter);
  }

  ///custom comparing function to check if two users are equal
  bool isEqual(UserModel model) {
    return this.id == model.id;
  }

  @override
  String toString() => name;
}