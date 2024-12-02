import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:wooda_client/src/components/image_data.dart';
import 'package:wooda_client/src/app.dart';
import 'package:wooda_client/src/models/detail_page_model.dart';
import 'package:wooda_client/src/screens/detail_page.dart';

class AllSchedulesPage extends StatefulWidget {
  final List<Map<String, dynamic>> schedules;
  final void Function(int id) onDelete; // 삭제 함수
  final void Function(Map<String, dynamic> updatedSchedule) onUpdate;

  const AllSchedulesPage({
    Key? key,
    required this.schedules,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  _AllSchedulesPageState createState() => _AllSchedulesPageState();
}

class _AllSchedulesPageState extends State<AllSchedulesPage> {
  int _currentIndex = 0; // 현재 BottomNavigationBar 인덱스
  int _selectedTabIndex = 2; // 기본값으로 "일기" 탭 선택

  List<Map<String, dynamic>> getFilteredAndSortedSchedules(String type) {
    final filteredSchedules = widget.schedules
        .where((schedule) => schedule["type"] == type)
        .toList();
    // "diary"일 경우 최신순 정렬, "schedule"일 경우 오래된 순 정렬
    filteredSchedules.sort((a, b) => type == "diary"
        ? b["date"].compareTo(a["date"]) // 최신순 정렬
        : a["date"].compareTo(b["date"])); // 오래된 순 정렬
    return filteredSchedules;
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
          automaticallyImplyLeading: false,
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
                'assets/images/background_04.png',
                fit: BoxFit.cover,
              ),
            ),
            if (_selectedTabIndex == 1) // "일정" 탭
              ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: getFilteredAndSortedSchedules("schedule").length,
                itemBuilder: (context, index) {
                  final schedule = getFilteredAndSortedSchedules("schedule")[index];
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
              )
            else if (_selectedTabIndex == 2) // "일기" 탭
              ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: getFilteredAndSortedSchedules("diary").length,
                itemBuilder: (context, index) {
                  final diary = getFilteredAndSortedSchedules("diary")[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(
                            schedule: diary,
                            model: DetailPageModel(
                              id: diary["id"],
                              title: diary["title"],
                              description: diary["description"],
                              date: diary["date"],
                              image: diary["image"],
                            ),
                            onDelete: () {
                              widget.onDelete(diary["id"]); // 부모로부터 전달된 함수 호출
                              setState(() {}); // 삭제 후 화면 갱신
                            },
                            onUpdate: (updatedSchedule) {
                              widget.onUpdate(updatedSchedule); // 부모로부터 전달된 함수 호출
                              setState(() {}); // 업데이트 후 화면 갱신
                            },
                          ),
                        ),
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 왼쪽: 사용자 프로필 및 이름
                        Align(
                          alignment: Alignment.topLeft,
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 10),
                                child: CircleAvatar(
                                  radius: 24,
                                  backgroundImage: AssetImage(
                                      'assets/images/profile_default.png'),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                diary["writer"] ?? "익명",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // 오른쪽: 카드
                        Expanded(
                          child: Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // 작성 날짜
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Text(
                                      "${diary["date"].year}/${diary["date"].month.toString().padLeft(2, '0')}/${diary["date"].day.toString().padLeft(2, '0')}",
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // 제목
                                  Text(
                                    diary["title"],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  // 내용
                                  Text(
                                    diary["description"],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // 하트 및 댓글 버튼
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.favorite_border,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {},
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.comment_outlined,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )

            else
              const Center(
                child: Text(
                  "표시할 내용이 없습니다.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
          ],
        ),
        // Bottom Navigation Bar
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          backgroundColor: Colors.white,
          currentIndex: _currentIndex,
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
