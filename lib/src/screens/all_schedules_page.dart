// all_schedules_page.dart
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
  int _currentIndex = 0; // 여기서 _currentIndex를 선언


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              "모아 보기",
              style: TextStyle(color: Colors.black),
            ),
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
            bottom: const TabBar(
              labelColor: Color(0xffFF5987),
              labelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              indicatorColor: Color(0xffFF5987), // 선택된 탭 아래 강조선
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 3,
              unselectedLabelColor: Color(0xff939393),
              unselectedLabelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600
              ),
              tabs: [
                Tab(text: "디데이"),
                Tab(text: "일정"),
                Tab(text: "일기"),
              ],
            ),
            actions: [
              IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.filter_list))
            ],
          ),
          body:  Stack(
            children: [
          // 배경 이미지
          Positioned.fill(
          child: Image.asset(
            'assets/images/background_04.png', // 배경 이미지 경로
            fit: BoxFit.cover, // 화면 크기에 맞게 이미지 채우기
          ),
        ),
          widget.schedules.isEmpty
              ? const Center(
            child: Text(
              "작성된 일정이 없습니다.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: widget.schedules.length,
            itemBuilder: (context, index) {
              final schedule = widget.schedules[index];
              return Card(
                elevation: 6,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                child: ListTile(
                  title: Text(schedule["title"]),
                  subtitle: Text(schedule["description"]),
                  trailing: Text(
                    "${schedule["date"].hour}:${schedule["date"].minute.toString().padLeft(2, '0')}",
                  ),
                ),
              );
            },
          ),
          ],
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
              if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>App(), ),);
              }
              else {
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
        )
        );
  }
}
