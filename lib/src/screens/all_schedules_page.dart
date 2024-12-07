import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wooda_client/src/models/detail_page_model.dart';
import 'package:wooda_client/src/models/items_model.dart';
import 'package:wooda_client/src/services/api_client_singleton.dart';
import 'package:wooda_client/src/screens/detail_page.dart';
import 'package:wooda_client/src/screens/app_screen.dart';
import 'package:wooda_client/src/components/image_data.dart';
import 'package:wooda_client/src/services/items_service.dart';

class AllSchedulesPage extends StatefulWidget {
  final Future<List<Item>> items;
  final void Function(int id) onDelete; // 삭제 함수
  final void Function(Item updatedSchedule) onUpdate;

  const AllSchedulesPage({
    super.key,
    required this.items,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  _AllSchedulesPageState createState() => _AllSchedulesPageState();
}

class _AllSchedulesPageState extends State<AllSchedulesPage> {
  int _currentIndex = 0; // 현재 BottomNavigationBar 인덱스
  int _selectedTabIndex = 2; // 기본값으로 "일기" 탭 선택
  DateTime _startDate = _calculateStartDate(DateTime.now());
  final ScrollController _scrollController = ScrollController();
  late final ItemsService itemsService = ItemsService(apiClient);

  // 현재 주의 시작 날짜 계산 함수
  static DateTime _calculateStartDate(DateTime referenceDate) {
    return referenceDate.subtract(Duration(days: referenceDate.weekday % 7));
  }

  // 현재 주의 시작 날짜와 끝 날짜 계산
  DateTime get _endDate => _startDate.add(const Duration(days: 6));

  void _changeWeek(int offset) {
    setState(() {
      _startDate = _startDate.add(Duration(days: 7 * offset));
      _scrollController.animateTo(
        0, // 슬라이드의 가장 왼쪽
        duration: const Duration(milliseconds: 300), // 애니메이션 지속 시간
        curve: Curves.easeOut, // 애니메이션 곡선
      );
    });
  }

  void toggleLike(Item schedule) {
    setState(() {
      const currentUserId = "user123"; // 예시 사용자 ID
      if (userLikes[schedule.id]?.contains(currentUserId) ?? false) {
        userLikes[schedule.id]?.remove(currentUserId); // 좋아요 제거
        schedule.likes--; // 좋아요 수 감소
      } else {
        userLikes.putIfAbsent(schedule.id, () => {}); // 초기화
        userLikes[schedule.id]!.add(currentUserId); // 좋아요 추가
        schedule.likes++; // 좋아요 수 증가
      }
    });
  }

  Future<List<Item>> getSchedulesForCurrentWeek(List<Item> items) async {
    return items.where((schedule) {
      return schedule.date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
          schedule.date.isBefore(_endDate.add(const Duration(days: 1)));
    }).toList();
  }

  Widget _buildWeekSelector() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => _changeWeek(-1),
          ),
          Text(
            "${DateFormat('MM.dd').format(_startDate)} - ${DateFormat('MM.dd').format(_endDate)}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.black),
            onPressed: () => _changeWeek(1),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySchedule(DateTime day, List<Item> daySchedules) {
    return Container(
      padding: const EdgeInsets.only(left: 20),
      width: 180,
      margin: const EdgeInsets.only(right: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜 표시
          Text(
            DateFormat('EEEE, MM.dd', 'ko_KR').format(day),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // 일정 표시 또는 "일정 없음" 메시지
          daySchedules.isEmpty
              ? const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Text(
                "일정 없음",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          )
              : ListView.builder(
            shrinkWrap: true,
            itemCount: daySchedules.length,
            itemBuilder: (context, index) {
              final item = daySchedules[index];
              return Text(item.title); // 일정 제목 출력
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryItem(Item diary) {
    final isLiked = userLikes[diary.id]?.contains("user123") ?? false;

    return GestureDetector(
      onTap: () {
        // 상세 페이지로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(
              item: diary,
              model: DetailPageModel(
                id: diary.id,
                title: diary.title,
                description: diary.description,
                date: diary.date,
                image: diary.image,
              ),
              onDelete: () {
                widget.onDelete(diary.id); // 부모로부터 전달된 함수 호출
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
          CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage('assets/images/profile_default.png'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(diary.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(diary.description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () => toggleLike(diary),
                    ),
                    Text('${diary.likes} likes'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Item>> getFilteredAndSortedSchedules(String type, List<Item> items) async {
    final filteredSchedules = items.where((schedule) => schedule.type == type).toList();

    // 정렬
    filteredSchedules.sort((a, b) {
      return type == "diary"
          ? b.date.compareTo(a.date) // 최신순 정렬
          : a.date.compareTo(b.date); // 오래된 순 정렬
    });

    return filteredSchedules;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Item>>(
      future: widget.items,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('오류 발생: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('표시할 일정이 없습니다.'));
        }

        final items = snapshot.data!;

        final schedulesByDay = List.generate(7, (index) {
          final day = _startDate.add(Duration(days: index));
          final daySchedules = items.where((schedule) {
            return schedule.date.day == day.day &&
                schedule.date.month == day.month &&
                schedule.date.year == day.year;
          }).toList();
          return {
            'date': day,
            'schedules': daySchedules,
          };
        });

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
            ),
            body: _selectedTabIndex == 1
                ? _buildWeeklySchedulesView(items, schedulesByDay)
                : _selectedTabIndex == 2
                ? _buildDiaryListView(items)
                : const Center(child: Text("표시할 내용이 없습니다.")),
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
                      builder: (context) => AppScreen(),
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
    );
  }

  Widget _buildWeeklySchedulesView(List<Item> items, List<Map<String, dynamic>> schedulesByDay) {
    return Column(
      children: [
        _buildWeekSelector(),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(7, (index) {
                final dayData = schedulesByDay[index];
                final daySchedules = dayData['schedules'] as List<Item>;
                final day = dayData['date'] as DateTime;

                return _buildDaySchedule(day, daySchedules);
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiaryListView(List<Item> items) {
    return FutureBuilder<List<Item>>(
      future: getFilteredAndSortedSchedules("diary", items),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('오류 발생: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('일기가 없습니다.'));
        }

        final diaries = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: diaries.length,
          itemBuilder: (context, index) {
            final diary = diaries[index];
            return _buildDiaryItem(diary);
          },
        );
      },
    );
  }
}
