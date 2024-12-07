// ///schedule_service.dart
// library;
//
// import 'package:wooda_client/src/models/items_model.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:wooda_client/src/data/local_schedules.dart';
//
// class ItemService {
//   List<Item> getSchedulesByType(String type) {
//     return localSchedules.where((item) => item.type == type).toList();
//   }
//
//   void deleteSchedule(int id) {
//     localSchedules.removeWhere((item) => item.id == id);
//   }
//
//   void updateSchedule(Item updatedSchedule) {
//     final index = localSchedules.indexWhere((item) => item.id == updatedSchedule.id);
//     if (index != -1) {
//       localSchedules[index] = updatedSchedule;
//     }
//   }
//
//   List<Item> getFilteredSchedules(DateTime selectedDay) {
//     return localSchedules.where((schedule) => isSameDay(schedule.date, selectedDay)).toList();
//   }
// }
