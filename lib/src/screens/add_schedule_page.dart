import 'package:flutter/material.dart';

class AddSchedulePage extends StatefulWidget {
  final DateTime dateTime;
  final String? initialTitle;
  final String? initialDescription;

  const AddSchedulePage({
    Key? key,
    required this.dateTime,
    this.initialDescription,
    this.initialTitle
  }) : super(key: key);

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("일정 추가"),
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
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty) {
                  Navigator.pop(context, {
                    "title": titleController.text,
                    "description": descriptionController.text,
                    "date": widget.dateTime,
                    "image": null,
                  });
                }
              },
              child: const Text("저장"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
