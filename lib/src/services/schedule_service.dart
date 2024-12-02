///schedule_service.dart

import 'package:wooda_client/src/models/schedule_model.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wooda_client/src/data/local_schedules.dart';

class ScheduleService {
  List<Schedule> getSchedulesByType(String type) {
    return localSchedules.where((schedule) => schedule.type == type).toList();
  }

  void deleteSchedule(int id) {
    localSchedules.removeWhere((schedule) => schedule.id == id);
  }

  void updateSchedule(Schedule updatedSchedule) {
    final index = localSchedules.indexWhere((schedule) => schedule.id == updatedSchedule.id);
    if (index != -1) {
      localSchedules[index] = updatedSchedule;
    }
  }

  List<Schedule> getFilteredSchedules(DateTime selectedDay) {
    return localSchedules.where((schedule) => isSameDay(schedule.date, selectedDay)).toList();
  }
}
