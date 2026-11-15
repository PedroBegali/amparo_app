import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const tokenKey = "amparo_token";

class ApiException implements Exception {
  ApiException(this.status, this.mensagem, [this.campos]);

  final int status;
  final String mensagem;
  final Map<String, dynamic>? campos;

  String get detalhe {
    if (campos != null && campos!.isNotEmpty) {
      return "$mensagem ${campos!.values.first}";
    }
    return mensagem;
  }

  @override
  String toString() => detalhe;
}

class OfflineException implements Exception {}

class ApiClient {
  ApiClient._();

  static const String _urlDefinida = String.fromEnvironment("API_URL");
  static const Duration timeout = Duration(seconds: 6);

  static String get baseUrl {
    if (_urlDefinida.isNotEmpty) return _urlDefinida;
    if (!kIsWeb && Platform.isAndroid) return "http://10.0.2.2:8080";
    return "http://localhost:8080";
  }

  static String? _token;

  static Future<void> salvarToken(String? token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    if (token == null) {
      await prefs.remove(tokenKey);
    } else {
      await prefs.setString(tokenKey, token);
    }
  }

  static Future<String?> _lerToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(tokenKey);
    return _token;
  }

  static Future<dynamic> get(String path) => _enviar("GET", path);

  static Future<dynamic> post(String path, Map<String, dynamic> body) =>
      _enviar("POST", path, body);

  static Future<dynamic> patch(String path, Map<String, dynamic> body) =>
      _enviar("PATCH", path, body);

  static Future<dynamic> _enviar(String metodo, String path,
      [Map<String, dynamic>? body]) async {
    final uri = Uri.parse("$baseUrl$path");
    final token = await _lerToken();
    final headers = {
      "Content-Type": "application/json; charset=utf-8",
      if (token != null) "Authorization": "Bearer $token",
    };

    http.Response resposta;
    try {
      switch (metodo) {
        case "POST":
          resposta = await http
              .post(uri, headers: headers, body: json.encode(body))
              .timeout(timeout);
          break;
        case "PATCH":
          resposta = await http
              .patch(uri, headers: headers, body: json.encode(body))
              .timeout(timeout);
          break;
        default:
          resposta = await http.get(uri, headers: headers).timeout(timeout);
      }
    } on SocketException {
      throw OfflineException();
    } on TimeoutException {
      throw OfflineException();
    } on http.ClientException {
      throw OfflineException();
    }

    final texto = utf8.decode(resposta.bodyBytes);
    if (resposta.statusCode >= 200 && resposta.statusCode < 300) {
      return texto.isEmpty ? null : json.decode(texto);
    }

    try {
      final erro = json.decode(texto) as Map<String, dynamic>;
      throw ApiException(resposta.statusCode, erro["mensagem"] ?? "Erro ${resposta.statusCode}",
          erro["campos"] as Map<String, dynamic>?);
    } on FormatException {
      throw ApiException(resposta.statusCode, "Erro ${resposta.statusCode} na API.");
    }
  }
}
