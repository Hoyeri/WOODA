import 'package:flutter/material.dart';
import 'package:wooda_client/src/components/image_data.dart';
import 'package:table_calendar/table_calendar.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _TableCalendarScreenState();
}
class _TableCalendarScreenState extends State<App> {
  CalendarFormat format = CalendarFormat.week;

  DateTime selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  DateTime focusedDay = DateTime.now();

  List<String> diaries = []; // 일기 데이터 리스트
  List<String> schedules = []; // 일정 데이터 리스트

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          /// AppBar
          appBar: AppBar(
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
                  fontSize: 21
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
              onPressed: () {},
            backgroundColor: const Color(0xffFF5987),
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            child: Icon(Icons.add),
          ),
          body: diaries.isEmpty
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
            padding: const EdgeInsets.all(16),
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(
                    schedules[index],
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        schedules.removeAt(index); // 일정 삭제
                      });
                    },
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
            currentIndex: 1, // 디폴트 버튼 == '나의 일상'
            onTap: (index) {
              setState(() {
              });
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