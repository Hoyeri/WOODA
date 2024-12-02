///app_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wooda_client/src/components/image_data.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wooda_client/src/models/detail_page_model.dart';
import 'package:wooda_client/src/screens/all_schedules_page.dart';
import 'package:wooda_client/src/screens/detail_page.dart';
import 'package:wooda_client/src/screens/date_time_selection_page.dart';
import 'package:wooda_client/src/screens/add_schedule_page.dart';
import 'package:wooda_client/src/data/local_schedules.dart';
import 'package:wooda_client/src/services/schedule_service.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({Key? key}) : super(key: key);

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  final ScheduleService _scheduleService = ScheduleService(); // ScheduleService 인스턴스
  CalendarFormat format = CalendarFormat.week;
  int _currentIndex = 1;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final filteredSchedules = _scheduleService.getFilteredSchedules(selectedDay);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        /// AppBar
        appBar: AppBar(
          backgroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          toolbarHeight: 90,
          flexibleSpace: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background_00.png'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  )
              )
          ),
          title: const Text(
            'WOODA',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 21,
              color: Colors.black
            ),
          ),
          centerTitle: true,
          elevation: 0,
          bottom: PreferredSize( /// AppBar 내 TableCalendar 구현
              preferredSize: const Size.fromHeight(95),
              child: TableCalendar(
                /// header 꾸미기
                headerStyle: HeaderStyle(
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                        fontSize: 15
                    ),
                    formatButtonVisible: false,
                    headerMargin: EdgeInsets.all(8.0),
                    headerPadding: EdgeInsets.all(0.0)
                ),
                calendarStyle: CalendarStyle(
                    isTodayHighlighted: false,
                    selectedDecoration:  const BoxDecoration(
                      color: Color(0xffFF5987),
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white
                    ),
                    defaultTextStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    todayTextStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white
                    ),
                    weekendTextStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600
                    )
                ),
                locale: 'ko_KR',
                focusedDay: focusedDay,
                onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                  // 선택된 날짜의 상태를 갱신
                  setState((){
                    this.selectedDay = selectedDay;
                    this.focusedDay = focusedDay;
                  });
                },
                selectedDayPredicate: (DateTime day) {
                  // selectedDay 와 동일한 날짜의 모양 변경
                  return isSameDay(selectedDay, day);
                },
                firstDay: DateTime.utc(2023, 12, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                calendarFormat: format,
                onFormatChanged: (CalendarFormat newFormat) {
                  setState(() {
                    format = newFormat;
                  });
                },
              )
          ),
          /// AppBar 윗부분 구현(검색, 알림 버튼)
          leading: IconButton.outlined(
            onPressed: () {},
            icon: Icon(Icons.search),
            color: const Color(0xffFF5987),
            iconSize: 28,
            style: OutlinedButton.styleFrom(
                side: BorderSide(
                    width: 1.5,
                    color: const Color(0xffFF5987))
            ),
          ),
          actions: [
            IconButton.outlined(
                onPressed: () {},
                icon: Icon(Icons.notifications_none),
                color: const Color(0xffFF5987),
                iconSize: 28,
                style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        width: 1.5,
                        color: const Color(0xffFF5987))
                )
            )
          ],
        ),

        /// floating button 구현
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // Step 1: 날짜 및 시간 선택
            final dateTimeResult = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DateTimeSelectionPage(),
              ),
            );

            if (dateTimeResult != null && dateTimeResult is Map<String, dynamic>) {
              DateTime dateTime = DateTime(
                dateTimeResult["date"].year,
                dateTimeResult["date"].month,
                dateTimeResult["date"].day,
                dateTimeResult["time"].hour,
                dateTimeResult["time"].minute,
              );

              // Step 2: 제목 및 내용 입력
              final scheduleResult = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddSchedulePage(dateTime: dateTime),
                ),
              );

              if (scheduleResult != null) {
                setState(() {
                  localSchedules.add(scheduleResult);
                });
              }
            }
          },
          backgroundColor: const Color(0xffFF5987),
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          child: Icon(Icons.add),
        ),
        body: filteredSchedules.isEmpty
            ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '작성된 일정/일기가 없어요.',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '+ 버튼으로 새로운 항목을 추가해 보세요!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                )
              ],
            )
        )
            : ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: filteredSchedules.length,
          itemBuilder: (context, index) {
            final schedule = filteredSchedules[index];
            final bool isDiary = schedule.type == "diary";

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              child: InkWell(
                onTap: () {
                  // 상세 페이지로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(
                        schedule: schedule,
                        model: DetailPageModel(
                          id: schedule.id,
                          title: schedule.title,
                          description: schedule.description,
                          date: schedule.date,
                          image: schedule.image,
                        ),
                        onDelete: () {
                          _scheduleService.deleteSchedule(schedule.id);
                        },
                        onUpdate: (updatedSchedule) {
                          _scheduleService.updateSchedule(updatedSchedule);
                        },
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 텍스트 영역
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 알약 형태의 레이블
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(
                                color: isDiary ? Color(0xffFFEF9E) : Color(0xffE5EBFC),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isDiary ? Icons.description : Icons.event,
                                    size: 14,
                                    color: isDiary ? Color(0xffC75F00) : Color(0xff1745C1),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    isDiary ? "일기" : "일정",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDiary ? Color(0xffC75F00) : Color(0xff1745C1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            // 제목 + 일시
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  schedule.title,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "${schedule.date.hour}:${schedule.date.minute.toString().padLeft(2, '0')}",
                                  style: TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            // 내용
                            Text(
                              schedule.description,
                              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 이미지 미리보기
                      ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                        child: (schedule.image != null && schedule.image!.isNotEmpty)
                            ? Image.asset(
                          schedule.image!,
                          width: 80, // 이미지 폭
                          height: 90, // 카드의 전체 높이에 맞춤
                          fit: BoxFit.cover,
                        )
                            : SizedBox(width: 80, height: 90),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        /// bottom navigation bar 구현
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          backgroundColor: Colors.white,
          currentIndex: _currentIndex, // 디폴트 버튼 == '나의 일상'

          /// 모아보기로 이동
          onTap: (index) {
            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllSchedulesPage(
                    schedules: localSchedules,
                    onUpdate: _scheduleService.updateSchedule,
                    onDelete: _scheduleService.deleteSchedule,
                  ),
                ),
              );
            } else {
              setState(() {
                _currentIndex = index;
              });
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: ImageData(IconsPath.homeOff, width: 70),
              activeIcon: ImageData(IconsPath.homeOn, width: 70),
              label: '모아 보기',
            ),
            BottomNavigationBarItem(
              icon: ImageData(IconsPath.diaryOff, width: 70),
              activeIcon: ImageData(IconsPath.diaryOn, width: 70),
              label: '나의 일상',
            ),
            BottomNavigationBarItem(
              icon: ImageData(IconsPath.friendsOff, width: 70),
              activeIcon: ImageData(IconsPath.friendsOn, width: 70),
              label: '친구들',
            ),
          ],
          selectedItemColor: const Color(0xffFF5987),
        ),
      ),
    );
  }
}