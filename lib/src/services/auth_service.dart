import 'dart:convert';
import 'package:wooda_client/src/services/api_client.dart';

class AuthService {
  final ApiClient apiClient;

  AuthService(this.apiClient);

  Future<String> getUsername() async {
    final response = await apiClient.get('/auth/getUsername');
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return response.body;
    }
  }
  Future<String?> getId() async {
    try {
      final response = await apiClient.get('/auth/getId');
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);

          if (data is Map<String, dynamic> && data.containsKey('user_id')) {
            return data['user_id'].toString();
          } else if (data is int) {
            return data.toString();
          } else {
            throw Exception('Unexpected response format: $data');
          }
        } catch (e) {
          // 응답이 JSON이 아니면 그대로 반환
          return response.body.toString();
        }
      } else {
        throw Exception('Failed to fetch user ID: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching user ID: $e");
      return null;
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

