// lib/services.dart
import 'dart:convert';
import 'package:wooda_client/src/services/api_client.dart';

class DiaryService {
  final ApiClient apiClient;

  DiaryService(this.apiClient);

  Future<void> createDiary(String title, String content) async {
    final response = await apiClient.post('/diary/create', {
      'title': title,
      'content': content,
    });
  }

  Future<void> getDiaries() async {
    final response = await apiClient.get('/diary/all');
  }
}

class FriendService {
  final ApiClient apiClient;

  FriendService(this.apiClient);

  Future<void> addFriend(String username) async {
    final response = await apiClient.post('/friends/add', {
      'username': username,
    });
  }

  Future<void> listFriends() async {
    final response = await apiClient.get('/friends/list');
  }
}

class ScheduleService {
  final ApiClient apiClient;

  ScheduleService(this.apiClient);

  Future<void> createSchedule(String event, String date, String? location) async {
    final response = await apiClient.post('/schedule/create', {
      'event': event,
      'date': date,
      'location': location,
    });
  }

  Future<void> getSchedules() async {
    final response = await apiClient.get('/schedule/all');
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      print('Schedules:');
      for (var schedule in data) {
        print('Event: ${schedule['event']}');
        print('Date: ${schedule['date']}');
        print('Location: ${schedule['location'] ?? 'N/A'}');
        print('---');
      }
    } else {
      print('Failed to fetch schedules: ${data['message']}');
    }
  }
}



