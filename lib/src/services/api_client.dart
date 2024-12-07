// lib/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  String? authToken;

  ApiClient({required this.baseUrl, required this.authToken});

  void setAuthToken(String token) {
    authToken = token;
  }


  Future<http.Response> post(String path, Map<String, dynamic> data) {
    return http.post(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken', // JWT 토큰 추가
      },
      body: jsonEncode(data),
    );
  }

  Future<http.Response> put(String path, Map<String, dynamic> data) {
    return http.put(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken', // JWT 토큰 추가
      },
      body: jsonEncode(data),
    );
  }

  Future<http.Response> get(String path) {
    return http.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers(),
    );
  }

  Future<http.Response> delete(String path) {
    return http.delete(
      Uri.parse('$baseUrl$path'),
      headers: _headers(),
    );
  }

  Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };
  }
}
