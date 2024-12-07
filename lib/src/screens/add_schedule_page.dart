import 'package:flutter/material.dart';
import 'package:wooda_client/src/services/items_service.dart';
import 'package:wooda_client/src/screens/app_screen.dart';
import 'package:wooda_client/src/services/api_client_singleton.dart';

class AddItemPage extends StatefulWidget {
  final DateTime dateTime;

  const AddItemPage({super.key, required this.dateTime});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool isSchedule = true; // 기본값은 일정

  final ItemsService itemsService = ItemsService(apiClient); // 에뮬레이터용 URL

  Future<void> saveItem() async {
    print("Selected Date: ${widget.dateTime.toIso8601String()}"); // 로그 추가

    try {
      final response = await itemsService.createItem(
        type: isSchedule ? "schedule" : "diary",
        title: titleController.text,
        description: descriptionController.text,
        date: widget.dateTime.toIso8601String(),
      );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("저장 성공!")),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AppScreen()),
              (route) => false, // 모든 이전 화면 제거
        ); // 성공 시 이전 화면으로 돌아가기
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("저장 실패: ${response['message']}")),
        );
      }
    } catch (e) {
      print("Error saving item: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("저장 실패: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("일정 / 일기 추가"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "선택된 날짜 및 시간: ${widget.dateTime}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            ToggleButtons(
              isSelected: [isSchedule, !isSchedule],
              onPressed: (index) {
                setState(() {
                  isSchedule = index == 0; // 0: 일정, 1: 일기
                });
              },
              borderRadius: BorderRadius.circular(10),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text("일정"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text("일기"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "제목",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: "내용",
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: saveItem,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("저장"),
            ),
          ],
        ),
      ),
    );
  }
}
