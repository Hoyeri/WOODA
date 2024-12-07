import 'dart:convert';
import 'package:wooda_client/src/models/items_model.dart';
import 'package:wooda_client/src/services/api_client.dart';

class ItemsService {
  final ApiClient apiClient;

  ItemsService(this.apiClient);

  Future<Map<String, dynamic>> createItem({
    required String type, // "schedule" or "diary"
    required String title,
    required String description,
    String? image,
    required String date, // 선택된 날짜 필드
  }) async {
    final response = await apiClient.post('/items/create', {
      "type": type,
      "title": title,
      "description": description,
      "date": date, // 선택된 날짜 전달
      if (image != null) "image": image, // 이미지가 있을 경우 추가
    });

    if (response.statusCode == 201) {
      return {"status": "success", "message": "Item created successfully"};
    } else {
      final body = jsonDecode(response.body);
      return {
        "status": "error",
        "message": body["message"] ?? "Error creating item",
      };
    }
  }


  Future<List<Item>> getItemsByDate(DateTime selectedDate) async {
    final dateStr = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
    final response = await apiClient.get('/items/by-date?date=$dateStr');

    // API 응답 상태 코드와 바디를 로그로 출력
    print("API 응답 상태 코드: ${response.statusCode}");
    print("API 응답 바디: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = jsonDecode(response.body);
        // JSON 데이터를 Item 객체로 변환
        return data.map((json) {
          try {
            return Item.fromJson(json);
          } catch (e) {
            print("Item 변환 오류: $e, 문제의 JSON 데이터: $json");
            rethrow;
          }
        }).toList();
      } catch (e) {
        throw Exception("JSON 디코딩 또는 Item 변환 오류: $e");
      }
    } else {
      throw Exception("서버 응답 오류: ${response.statusCode}, 메시지: ${response.body}");
    }
  }


  Future<List<Item>> getItems() async {
    final response = await apiClient.get('/items/all');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception("Error fetching items: ${response.body}");
    }
  }

  Future<List<Item>> getItemsByType(String type) async {
    final items = await getItems();
    return items.where((item) => item.type == type).toList();
  }

  Future<Map<String, dynamic>> deleteItem(int id) async {
    final response = await apiClient.delete('/items/delete/$id');
    if (response.statusCode == 200) {
      return {"status": "success", "message": "Item deleted successfully"};
    } else {
      final body = jsonDecode(response.body);
      return {
        "status": "error",
        "message": body["message"] ?? "Error deleting item"
      };
    }
  }

  Future<Map<String, dynamic>> updateItem(Item updatedItem) async {
    final response = await apiClient.put('/items/update/${updatedItem.id}', {
      "type": updatedItem.type,
      "title": updatedItem.title,
      "description": updatedItem.description,
      "date": updatedItem.date.toIso8601String(),
      "image": updatedItem.image,
    });

    // 상태 코드 확인
    if (response.statusCode == 200) {
      try {
        final body = jsonDecode(response.body);
        return {"status": "success", "message": "Item updated successfully", "data": body};
      } catch (e) {
        throw FormatException("Failed to parse JSON: ${response.body}");
      }
    } else {
      try {
        final body = jsonDecode(response.body);
        return {"status": "error", "message": body["message"] ?? "Unknown error"};
      } catch (e) {
        throw Exception("Unexpected response: ${response.body}");
      }
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<List<Item>> getFilteredItems(DateTime selectedDay) async {
    final items = await getItems();
    return items.where((item) => isSameDay(item.date, selectedDay)).toList();
  }
}