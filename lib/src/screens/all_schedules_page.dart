import 'package:flutter/material.dart';
import 'package:wooda_client/src/components/image_data.dart';
import 'package:wooda_client/src/app.dart';

class AllSchedulesPage extends StatefulWidget {
  final List<Map<String, dynamic>> schedules;

  const AllSchedulesPage({Key? key, required this.schedules}) : super(key: key);

  @override
  _AllSchedulesPageState createState() => _AllSchedulesPageState();
}

class _AllSchedulesPageState extends State<AllSchedulesPage> {
  int _currentIndex = 0; // 현재 BottomNavigationBar 인덱스
  int _selectedTabIndex = 1; // 현재 TabBar 인덱스

  List<Map<String, dynamic>> getFilteredAndSortedSchedules(String type) {
    return widget.schedules
        .where((schedule) => schedule["type"] == type)
        .toList()
      ..sort((a, b) => a["date"].compareTo(b["date"]));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: _selectedTabIndex,
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          title: const Text(
            "모아 보기",
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: false,
          titleTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
          bottom: TabBar(
            labelColor: const Color(0xffFF5987),
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            indicatorColor: const Color(0xffFF5987),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 3,
            unselectedLabelColor: const Color(0xff939393),
            unselectedLabelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: "디데이"),
              Tab(text: "일정"),
              Tab(text: "일기"),
            ],
            onTap: (index) {
              setState(() {
                _selectedTabIndex = index;
              });
            },
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.filter_list),
            ),
          ],
        ),
        body: Stack(
          children: [
            // 배경 이미지
            Positioned.fill(
              child: Image.asset(
                'assets/images/background_04.png', // 배경 이미지 경로
                fit: BoxFit.cover, // 화면 크기에 맞게 이미지 채우기
              ),
            ),
            if (_selectedTabIndex == 1 || _selectedTabIndex == 2) // 일정 또는 일기 탭
              ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: _selectedTabIndex == 1
                    ? getFilteredAndSortedSchedules("schedule").length
                    : getFilteredAndSortedSchedules("diary").length,
                itemBuilder: (context, index) {
                  final filteredSchedules = _selectedTabIndex == 1
                      ? getFilteredAndSortedSchedules("schedule")
                      : getFilteredAndSortedSchedules("diary");
                  final schedule = filteredSchedules[index];

                  return Card(
                    elevation: 6,
                    margin: const EdgeInsets.symmetric(
                        vertical: 6, horizontal: 10),
                    child: ListTile(
                      title: Text(schedule["title"]),
                      subtitle: Text(schedule["description"]),
                      trailing: Text(
                        "${schedule["date"].hour}:${schedule["date"].minute.toString().padLeft(2, '0')}",
                      ),
                    ),
                  );
                },
              )
            else
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '표시할 디데이가 없어요😢',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '+ 버튼으로 디데이를 추가해 보세요!',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    )
                  ],
                )
              ),
          ],
        ),

        /// BottomNavigationBar
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          backgroundColor: Colors.white,
          currentIndex: _currentIndex, // 디폴트 버튼 == '나의 일상'

          /// 모아보기로 이동
          onTap: (index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => App(),
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
