import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // ImagePicker 패키지 추가
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
  TimeOfDay selectedTime = TimeOfDay.now();
  File? _selectedImage; // 선택된 이미지 저장

  final ItemsService itemsService = ItemsService(apiClient);

  Future<void> saveItem() async {
    try {
      final response = await itemsService.createItem(
        type: isSchedule ? "schedule" : "diary",
        title: titleController.text,
        description: descriptionController.text,
        date: DateTime(
          widget.dateTime.year,
          widget.dateTime.month,
          widget.dateTime.day,
          selectedTime.hour,
          selectedTime.minute,
        ).toIso8601String(),
        image: _selectedImage?.path, // 선택된 이미지 경로를 서버로 전달
      );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("저장 성공!")),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AppScreen()),
              (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("저장 실패: ${response['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("저장 실패: $e")),
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile =
      await picker.pickImage(source: ImageSource.gallery); // 갤러리에서 이미지 선택
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path); // 선택된 이미지 파일 저장
        });
        print("이미지 선택 성공: ${pickedFile.path}");
      } else {
        print("이미지가 선택되지 않았습니다.");
      }
    } catch (e) {
      print("이미지 선택 중 오류 발생: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("이미지 선택 실패: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "일기 쓰기",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xff333333),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 선택된 날짜 및 시간 표시
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${widget.dateTime.year}년 ${widget.dateTime.month}월 ${widget.dateTime.day}일, ${["일", "월", "화", "수", "목", "금", "토"][widget.dateTime.weekday % 7]}요일",
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Colors.black45,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (pickedTime != null) {
                        setState(() {
                          selectedTime = pickedTime;
                        });
                      }
                    },
                    child: Row(
                      children: [
                        Text(
                          "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Color(0xffFF5987),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.access_time,
                            size: 15, color: Color(0xffFF5987)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 0),
            // 일정/일기 선택
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isSchedule = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSchedule ? const Color(0xffFF5987) : Colors.white,
                      border: Border.all(color: const Color(0xffFF5987)),
                    ),
                    child: Icon(
                      Icons.event,
                      color: isSchedule ? Colors.white : const Color(0xffFF5987),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isSchedule = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: !isSchedule ? const Color(0xffFF5987) : Colors.white,
                      border: Border.all(color: const Color(0xffFF5987)),
                    ),
                    child: Icon(
                      Icons.description,
                      color: !isSchedule ? Colors.white : const Color(0xffFF5987),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 제목 입력
            Container(
              decoration: BoxDecoration(
                color: const Color(0xffF9F9F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xffE0E0E0)),
              ),
              child: TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: "제목을 입력하세요",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 내용 입력
            Container(
              decoration: BoxDecoration(
                color: const Color(0xffF9F9F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xffE0E0E0)),
              ),
              child: TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: "내용을 입력하세요",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                maxLines: 7,
              ),
            ),
            const SizedBox(height: 16),
            // 사진 추가
            // 사진 추가
            GestureDetector(
              onTap: _pickImage,
              child: _selectedImage == null
                  ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xffCECECE),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xffE0E0E0)),
                ),
                child: const Text(
                  "사진 추가",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black54),
                ),
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(20), // 이미지 모서리를 둥글게 설정
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.transparent, // 배경색 제거
                  ),
                  child: Image.file(
                    _selectedImage!,
                    width: double.infinity,
                    height: 400,
                    fit: BoxFit.cover, // 이미지가 컨테이너 크기에 맞게 채워짐
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: saveItem,
        backgroundColor: const Color(0xffFF5987),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Text(
          "등록",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
