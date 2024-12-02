/// edit_schedule_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wooda_client/src/models/schedule_model.dart';


class EditSchedulePage extends StatefulWidget {
  final Schedule schedule;
  final void Function(Schedule) onUpdate;

  const EditSchedulePage({
    Key? key,
    required this.schedule,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _EditSchedulePageState createState() => _EditSchedulePageState();
}

class _EditSchedulePageState extends State<EditSchedulePage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.schedule.title);
    _descriptionController =
        TextEditingController(text: widget.schedule.description);
    _selectedDate = widget.schedule.date;
    _imagePath = widget.schedule.image;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitChanges() {
    Schedule updatedSchedule = Schedule( /// schedule 객체로 변경
      id: widget.schedule.id, // 기존 ID 유지
      type: widget.schedule.type,
      writer: widget.schedule.writer,
      title: _titleController.text,
      description: _descriptionController.text,
      date: _selectedDate,
      image: widget.schedule.image, // 이미지 변경 없이 기존 이미지 유지
    );
    widget.onUpdate(updatedSchedule);
    Navigator.pop(context);
  }

  Future<void> _pickDateTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDateTime =
    DateFormat('yyyy년 MM월 dd일 EEEE, HH:mm', 'ko_KR').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
          iconSize: 23,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // 날짜 및 시간 선택 영역
          InkWell(
            onTap: () => _pickDateTime(context),
            child: Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                formattedDateTime,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // 나머지 UI 그대로 유지
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/background_01.png',
                    fit: BoxFit.fill,
                  ),
                ),
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 55,
                          child: TextField(
                            style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 15
                            ),
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: "제목",
                              labelStyle: const TextStyle(
                                color: Colors.black38,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 15
                          ),
                          maxLength: 800,
                          controller: _descriptionController,
                          maxLines: 8,
                          decoration: InputDecoration(
                            labelText: "내용",
                            labelStyle: const TextStyle(
                                color: Colors.black38
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black12,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_imagePath != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              _imagePath!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 400,
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        const SizedBox(height: 6),
                        ElevatedButton(
                          onPressed: _submitChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffFF5987),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "등록",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
