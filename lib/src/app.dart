/// app.dart

import 'package:flutter/material.dart';
import 'package:wooda_client/src/components/image_data.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wooda_client/src/models/detail_page_model.dart';
import 'package:wooda_client/src/screens/all_schedules_page.dart';
import 'package:wooda_client/src/screens/detail_page.dart';
import 'package:wooda_client/src/screens/date_time_selection_page.dart';
import 'package:wooda_client/src/screens/add_schedule_page.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _TableCalendarScreenState();
}

class _TableCalendarScreenState extends State<App> {
  CalendarFormat format = CalendarFormat.week;

  int _currentIndex = 1;

  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  List<String> diaries = []; // 일기 데이터 리스트
  List<String> schedules = []; // 일정 데이터 리스트

  List<Map<String, dynamic>> getFilteredSchedules() {
    return localSchedules
        .where((schedule) => isSameDay(schedule["date"], selectedDay))
        .toList()
      ..sort((a, b) => a["date"].compareTo(b["date"]));

  }

  void _deleteSchedule(int id) {
    setState(() {
      localSchedules.removeWhere((schedule) => schedule["id"] == id);
    });

  }

  void _updateSchedule(Map<String, dynamic> updatedSchedule) {
    setState(() {
      final index = localSchedules.indexWhere(
            (schedule) => schedule["id"] == updatedSchedule["id"],
      );
      if (index != -1) {
        localSchedules[index] = updatedSchedule;
      }
    });
  }





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

                if (scheduleResult != null && scheduleResult is Map<String, dynamic>) {
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
          body: getFilteredSchedules().isEmpty
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
            itemCount: getFilteredSchedules().length,
            itemBuilder: (context, index) {
              final schedule = getFilteredSchedules()[index];
              final bool isDiary = schedule["type"] == "diary";

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
                            id: schedule["id"],
                            title: schedule["title"],
                            description: schedule["description"],
                            date: schedule["date"],
                            image: schedule["image"],
                          ),
                          onDelete: () {
                            _deleteSchedule(schedule["id"]);
                          },
                          onUpdate: (updatedSchedule) {
                            _updateSchedule(updatedSchedule);
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
                                    schedule["title"],
                                    style: TextStyle(
                                        fontSize: 15,
                                      fontWeight: FontWeight.w600
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "${schedule["date"].hour}:${schedule["date"].minute.toString().padLeft(2, '0')}",
                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              // 내용
                              Text(
                                schedule["description"],
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
                          child: schedule["image"] != null
                              ? Image.asset(
                            schedule["image"],
                            width: 80, // 이미지 폭
                            height: 90, // 카드의 전체 높이에 맞춤
                            fit: BoxFit.cover,
                          )
                              : SizedBox(width: 80,height: 90)
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
                    builder: (context) => AllSchedulesPage(schedules: localSchedules),
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




/// test data
List<Map<String, dynamic>> localSchedules = [
  {
    "id": 1,
    "writer": "홍예림",
    "type": "diary",
    "title": "생일 축하해",
    "date": DateTime(2024, 12, 2, 13, 0),
    "description": "오늘은 재우 생일이라서 제로 머리에 귀여운 빨간 리본을 달았다. 재우가 엄청 좋아해줘서 나도 기분이 좋았다. 미역국도 끓였는데 언제나처럼.. 간을 잘 못 맞춰서 조금 속상했다. 나는 언제쯤 요리 고수가 될 수 있을까? 이번 방학에는 엄마한테 요리를 배워야겠다. 그나저나 제로가 요즘 밥을 잘 안 먹는다. 안 그래도 작은데 밥까지 안 먹으니 금방 쓰러져 버릴 것 같아서 걱정이다. 제로야 밥 좀 먹어~! ㅠ",
    "image": "assets/images/snowman.jpg",
  },
  {
    "id": 2,
    "writer": "홍예림",
    "type": "schedule",
    "title": "헬스장 운동",
    "date": DateTime(2024, 12, 3, 18, 30),
    "description": "PT 수업 + 무산소 + 유산소",
  },
  {
    "id": 3,
    "writer": "홍예림",
    "type": "schedule",
    "title": "친구와 저녁 약속",
    "date": DateTime(2024, 12, 7, 19, 0),
    "description": "소울피 가서 피자랑 오븐 스파게티 먹을 거임",
  },
  {
    "id": 4,
    "type": "diary",
    "writer": "홍예림",
    "title": "홍쭐리 키우기",
    "date": DateTime(2024, 12, 3, 14, 0),
    "description": "쭐리야 무럭무럭 자라줘! 홍쭐의 매력 포인트는 코에 있는 검은 점이랑 목 뒤에 있는 하얀 후드, 오동통한 쿠앤크 꼬리 ㅎ ㅎ 그리고 보석 같은 눈이에요.",
  },
  {
    "id": 5,
    "type": "diary",
    "writer": "홍예림",
    "title": "기념일",
    "date": DateTime(2024, 12, 6, 7, 0),
    "description": "나는 네가 너라서 좋아. 말투도 표정도 걸음걸이도 다 너다워서 좋고, 편지에 써준 글도 딱 너 같아서 기분이 좋아. 마음에는 뭐가 많은데 말로 표현하기가 어렵다.. 그래서 오늘 일기는 이게 다야! 언제부터인지 모르게 마음에 들어와 버렸어.",
  },
  {
    "id": 6,
    "writer": "홍예림",
    "type": "schedule",
    "title": "동생 과외하기",
    "date": DateTime(2024, 12, 8, 16, 0),
    "description": "귀찮다",
  },
  {
    "id": 7,
    "writer": "김구리",
    "type": "diary",
    "title": "공휴일은 학교 안 가는 날",
    "date": DateTime(2024, 12, 8, 16, 0),
    "description": "한글날이라 오늘은 강의가 없어서 중도에서 공부를 했다. 가끔은 이렇게 쉬어가는 시간도 필요하다는 걸 절실히 느꼈다. 그럼 내일 또 쉬어도 되나?",
  },
  {
    "id": 8,
    "writer": "수원맘",
    "type": "diary",
    "title": "마크에서 살아남기",
    "date": DateTime(2024, 12, 8, 16, 0),
    "description": "상숭이랑 예림언니랑 유빈이랑 같이 마인크래프트에서 다이아 캐기 장인이 되었다. 상원이 거 뺏는 게 세상에서 젤 재밌더라",
  },
  {
    "id": 9,
    "writer": "김구리",
    "type": "schedule",
    "title": "과외",
    "date": DateTime(2024, 12, 8, 16, 0),
    "description": "하기 싫지만 버텨야지",
  },
  {
    "id": 10,
    "writer": "수원맘",
    "type": "schedule",
    "title": "팀플하러 중도 가기",
    "date": DateTime(2024, 12, 8, 16, 0),
    "description": "귀찮다",
  },
];