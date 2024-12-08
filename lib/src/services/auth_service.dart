import 'dart:convert';
import 'package:wooda_client/src/services/api_client.dart';

class AuthService {
  final ApiClient apiClient;

  AuthService(this.apiClient);

  Future<String> getUsername(int id) async {
    final response = await apiClient.post('/auth/getUsername/$id', {'id': id});
    if (response.statusCode == 201) {
      return response.body;
    } else if (response.statusCode == 409) {
      return "Username already exists";
    } else {
      return response.body;
    }
  }
  Future<Map<String, dynamic>> register(String username, String password) async {
    final response = await apiClient.post('/auth/register', {
      'username': username,
      'password': password,
    });
    if (response.statusCode == 201) {
      return {"status": "success", "message": "User registered successfully"};
    } else if (response.statusCode == 409) {
      return {"status": "error", "message": "Username already exists"};
    } else {
      return {"status": "error", "message": response.body};
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await apiClient.post('/auth/login', {
      'username': username,             // 서버와 일치
      'password': password,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      apiClient.setAuthToken(token); // JWT 토큰 저장
      return {"status": "success", "message": "User logged in successfully"};
    } else if (response.statusCode == 401) {
      return {"status": "error", "message": "Invalid credentials"};
    } else {
      return {"status": "error", "message": response.body};
    }
  }
}
