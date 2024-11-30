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

  DateTime selectedDay = DateTime.now();
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
          body: localSchedules.isEmpty
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
            padding: EdgeInsets.all(15),
            itemCount: localSchedules.length,
            itemBuilder: (context, index) {
              final schedule = localSchedules[index];
              return Card(
                elevation: 6,
                margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10), // 항목 간 간격
                child: SizedBox(
                  height: 90, // 항목 높이
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          schedule["title"],
                          style: TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "${schedule["date"].hour}:${schedule["date"].minute.toString().padLeft(2, '0')}",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      schedule["description"],
                      style: TextStyle(color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: schedule["image"] != null
                          ? Image.asset(
                        schedule["image"],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                          : SizedBox(width: 50, height: 50),
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

/// test data
List<Map<String, dynamic>> localSchedules = [
  {
    "id": 1,
    "title": "눈사람 만들기",
    "date": DateTime(2023, 12, 5, 10, 0),
    "description": "눈 얼마나 오는지 보고 눈사람 만들러 나가기",
    "image": "assets/images/snowman.jpg",
  },
  {
    "id": 2,
    "title": "헬스장 운동",
    "date": DateTime(2023, 12, 6, 18, 30),
    "description": "PT 수업 및 유산소 운동",
  },
  {
    "id": 3,
    "title": "친구와 저녁 약속",
    "date": DateTime(2023, 12, 7, 19, 0),
    "description": "홍대 이탈리안 레스토랑 예약",
  },
  {
    "id": 4,
    "title": "코드 리뷰",
    "date": DateTime(2023, 12, 8, 14, 0),
    "description": "팀원과 함께 코드 최적화 작업",
  },
  {
    "id": 5,
    "title": "뭐하지?",
    "date": DateTime(2023, 12, 8, 14, 0),
    "description": "뭐할지 모르겠다",
  },
  {
    "id": 6,
    "title": "뭐하지?",
    "date": DateTime(2023, 12, 8, 14, 0),
    "description": "뭐할지 모르겠다",
  },
];