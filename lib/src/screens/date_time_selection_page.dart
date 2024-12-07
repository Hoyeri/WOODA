import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wooda_client/src/screens/add_schedule_page.dart';

class DateTimeSelectionPage extends StatefulWidget {
  const DateTimeSelectionPage({super.key});

  @override
  State<DateTimeSelectionPage> createState() => _DateTimeSelectionPageState();
}

class _DateTimeSelectionPageState extends State<DateTimeSelectionPage> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

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
          "날짜 선택",
          style: TextStyle(
            color: Color(0xff333333),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 상단 월 이동 컨트롤러
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xffFF5987)),
                  onPressed: () {
                    setState(() {
                      selectedDate = DateTime(selectedDate.year, selectedDate.month - 1);
                    });
                  },
                ),
                Text(
                  "${selectedDate.year}년 ${selectedDate.month}월",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xff333333),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Color(0xffFF5987)),
                  onPressed: () {
                    setState(() {
                      selectedDate = DateTime(selectedDate.year, selectedDate.month + 1);
                    });
                  },
                ),
              ],
            ),
          ),
          // 캘린더
          TableCalendar(
            focusedDay: selectedDate,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) => isSameDay(day, selectedDate),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                selectedDate = selectedDay;
              });
            },
            headerVisible: false,
            calendarStyle: CalendarStyle(
              todayDecoration: const BoxDecoration(
                color: Color(0xffFFB4C7),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Color(0xffFF5987),
                shape: BoxShape.circle,
              ),
              defaultTextStyle: const TextStyle(color: Color(0xff333333)),
              weekendTextStyle: const TextStyle(color: Color(0xffFF5987)),
              outsideDaysVisible: false,
            ),
          ),
          const SizedBox(height: 16),
          // 선택된 날짜 표시
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일, ${["일", "월", "화", "수", "목", "금", "토"][selectedDate.weekday % 7]}요일",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff333333),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "선택한 날짜로 진행할까요?",
                  style: TextStyle(fontSize: 14, color: Color(0xff666666)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 시간 선택
          ListTile(
            title: const Text(
              "선택된 시간",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff333333)),
            ),
            subtitle: Text(
              "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xffFF5987)),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.access_time, color: Color(0xffFF5987)),
              onPressed: () async {
                final TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (pickedTime != null) {
                  setState(() {
                    selectedTime = pickedTime;
                  });
                }
              },
            ),
          ),
          const Spacer(),
          // 다음 단계로 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: ElevatedButton(
              onPressed: () {
                final DateTime combinedDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddItemPage(dateTime: combinedDateTime),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffFF5987),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: const Size(double.infinity, 50), // 버튼 크기
              ),
              child: const Text(
                "다음 단계로",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
