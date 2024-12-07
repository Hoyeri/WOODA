import 'dart:convert';
import 'package:wooda_client/src/services/api_client.dart';
import 'package:wooda_client/src/models/friends_model.dart';

class FriendsService {
  final ApiClient apiClient;
  final List<Map<String, dynamic>> _friends = []; // 로컬에 캐싱된 친구 목록

  FriendsService(this.apiClient);

  // 친구 목록 조회
  Future<List<Friend>> getFriends() async {
    final response = await apiClient.get('/friends/list'); // '/list' 경로로 요청
    if (response.statusCode == 200) {
      print(response.body);
      print(jsonDecode(response.body));
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Friend.fromJson(json)).toList(); // JSON을 Friend 객체로 변환
    } else {
      throw Exception("Failed to fetch friends: ${response.body}");
    }
  }


  // 친구 추가
  Future<Map<String, dynamic>> addFriend(String friendUsername) async {
    final response = await apiClient.post('/friends/add', {
      "friend_username": friendUsername,
    });

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      // 친구 추가 성공 시 목록 갱신
      await getFriends();
      return {"status": "success", "message": body["message"] ?? "Friend added successfully"};
    } else {
      final body = jsonDecode(response.body);
      return {"status": "error", "message": body["message"] ?? "Error adding friend"};
    }
  }

  // 친구 삭제
  Future<Map<String, dynamic>> removeFriend(String userId, String friendUsername) async {
    final response = await apiClient.post('/friends/remove', {
      "user_id": userId,
      "friend_username": friendUsername,
    });

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      // 친구 삭제 성공 시 목록 갱신
      await getFriends();
      return {"status": "success", "message": body["message"] ?? "Friend removed successfully"};
    } else {
      final body = jsonDecode(response.body);
      return {"status": "error", "message": body["message"] ?? "Error removing friend"};
    }
  }

  // 로컬에서 친구 목록 가져오기
  List<Map<String, dynamic>> getLocalFriends() {
    return _friends;
  }

  // 친구가 있는지 확인
  bool isFriend(String username) {
    return _friends.any((friend) => friend['username'] == username);
  }
}
