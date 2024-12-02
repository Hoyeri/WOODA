import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DateTimeSelectionPage extends StatefulWidget {
  const DateTimeSelectionPage({Key? key}) : super(key: key);

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
        title: const Text("날짜 및 시간 선택"),
      ),
      body: Column(
        children: [
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
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text("선택된 시간"),
            subtitle: Text(
                "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}"),
            trailing: IconButton(
              icon: const Icon(Icons.access_time),
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
          ElevatedButton( ///그냥 버튼으로 수정
            onPressed: () {
              Navigator.pop(context, {
                "date": selectedDate,
                "time": selectedTime,
              });
            },
            child: const Text("다음 단계로",),
          ),
        ],
      ),
    );
  }
}
