import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthServices extends ChangeNotifier {
  final String _baseUrl = "medicprohn.app";

  final storage = new FlutterSecureStorage();

  Future<String?> login(String email, String password) async {
    final Map<String, dynamic> authData = {
      'usuario': email,
      'password': password
    };

    final url = Uri.https(_baseUrl, '/core/api_rest/login');

    final resp = await http.post(url, body: authData);

    final Map<String, dynamic> decodeData = json.decode(resp.body);

    if (decodeData.containsKey("token")) {
      print(decodeData);
      await storage.write(key: 'token', value: decodeData['token']);
      return null;
    } else {
      return decodeData['msj'];
    }
  }
  Future<String> readToken() async { 
    return await storage.read(key: 'token') ?? '';

  }
}
