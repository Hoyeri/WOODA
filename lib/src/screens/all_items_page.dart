import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wooda_client/src/models/detail_page_model.dart';
import 'package:wooda_client/src/models/items_model.dart';
import 'package:wooda_client/src/services/api_client_singleton.dart';
import 'package:wooda_client/src/screens/detail_page.dart';
import 'package:wooda_client/src/screens/app_screen.dart';
import 'package:wooda_client/src/components/image_data.dart';
import 'package:wooda_client/src/services/items_service.dart';
import 'package:wooda_client/src/screens/comment_page.dart';

class AllItemsPage extends StatefulWidget {
  final Future<List<Item>> items;
  final void Function(int id) onDelete; // 삭제 함수
  final void Function(Item updatedSchedule) onUpdate;

  const AllItemsPage({
    super.key,
    required this.items,
    required this.onUpdate,
    required this.onDelete,
  });


  @override
  _AllItemsPageState createState() => _AllItemsPageState();
}

class _AllItemsPageState extends State<AllItemsPage> {
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

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  void _fetchItems() async {
    try {
      final items = await widget.items; // 서버로부터 아이템 목록 가져오기
      setState(() {
        for (var item in items) {
          // 서버에서 좋아요 상태를 갱신
          item.likes_users = item.likes_users; // 서버에서 받아온 좋아요 상태
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("아이템 가져오기 실패: $e")),
      );
    }
  }

  void toggleLike(Item item) async {
    try {
      await itemsService.toggleLike(item); // 서버에 좋아요 토글 요청
      setState(() {
        // 서버 요청이 성공하면 클라이언트 상태 업데이트
        const currentUserId = "user123"; // 예시 사용자 ID
        if (item.likes_users.contains(currentUserId)) {
          item.likes_users.remove(currentUserId);
          item.likes--; // 좋아요 수 감소v
        } else {
          item.likes_users.add(currentUserId);
          item.likes++; // 좋아요 수 증가
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("좋아요 토글 실패: $e")),
      );
    }
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
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      width: 200, // UI에 고정된 폭
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              DateFormat('EEEE, MMM d', 'ko_KR').format(day), // 날짜 포맷
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daySchedules.length,
            itemBuilder: (context, index) {
              final schedule = daySchedules[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(
                        itemsService: itemsService,
                        item: schedule,
                        model: DetailPageModel(
                          id: schedule.id,
                          title: schedule.title,
                          description: schedule.description,
                          date: schedule.date,
                          image: schedule.image,
                        ),
                        onDelete: () {
                          widget.onDelete(schedule.id);
                          setState(() {});
                        },
                        onUpdate: (updatedSchedule) {
                          widget.onUpdate(updatedSchedule);
                          setState(() {});
                        },
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 4.0,
                    child: SizedBox(
                      height: 120, // 일정 카드의 고정 높이
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: AssetImage(
                                      'assets/images/profile_default.png'),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        schedule.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('HH:mm')
                                            .format(schedule.date),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              schedule.description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }


  Widget _buildDiaryItem(Item item) {
    final isLiked = item.likes_users.contains("user123");

    return GestureDetector(
      onTap: () {
        // 상세 페이지로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(
              itemsService: itemsService,
              item: item,
              model: DetailPageModel(
                id: item.id,
                title: item.title,
                description: item.description,
                date: item.date,
                image: item.image,
              ),
              onDelete: () {
                widget.onDelete(item.id); // 부모로부터 전달된 함수 호출
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
                Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(item.description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () => toggleLike(item),
                    ),
                    Text('${item.likes} likes'),
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
            return schedule.type == "schedule" && // "schedule" 타입 필터링
                schedule.date.day == day.day &&
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
            body: Stack(
              children: [
                // 배경 이미지
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/background_04.png',
                    fit: BoxFit.cover, // 이미지를 화면 크기에 맞게 확장 또는 축소
                    alignment: Alignment.topCenter,
                  ),
                ),
                Column(
                  children: [
                    Expanded(
                      child: _selectedTabIndex == 0
                          ? const Center(child: Text("디데이 탭 내용"))
                          : _selectedTabIndex == 1
                          ? _buildWeeklySchedulesView(items, schedulesByDay)
                          : _buildDiaryListView(items),
                    ),
                  ],
                ),
              ],
            ),
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
      },
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

                // "schedule" 타입의 항목만 전달
                final filteredSchedules = daySchedules.where((schedule) => schedule.type == "schedule").toList();
                return _buildDaySchedule(day, filteredSchedules);
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

        final items = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isLiked = item.likes_users.contains("user123");

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailPage(
                      itemsService: itemsService,
                      item: item,
                      model: DetailPageModel(
                        id: item.id,
                        title: item.title,
                        description: item.description,
                        date: item.date,
                        image: item.image,
                      ),
                      onDelete: () {
                        try {
                          // 부모 위젯의 onDelete 호출
                          widget.onDelete(item.id); // 반환값이 없으므로 await 제거

                          // 로컬 상태 업데이트 및 UI 강제 갱신
                          setState(() {
                            items.removeWhere((i) => i.id == item.id); // 로컬 목록에서 제거
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("항목이 성공적으로 삭제되었습니다.")),
                          );
                        } catch (e) {
                          // 삭제 실패 알림
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("삭제 실패: $e")),
                          );
                        }
                      },

                      onUpdate: (updatedSchedule) {
                        widget.onUpdate(updatedSchedule);
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
                          item.user_id,
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
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
                                "${item.date.year}/${item.date.month.toString().padLeft(2, '0')}/${item.date.day.toString().padLeft(2, '0')}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // 제목
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            // 내용
                            Text(
                              item.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // 하트 및 댓글 버튼
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // 좋아요 수와 아이콘
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isLiked ? Icons.favorite : Icons.favorite_border,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => toggleLike(item),
                                    ),
                                    Text(
                                      '${item.likes}',
                                      style: const TextStyle(
                                          fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                // 댓글 수와 아이콘
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.comment_outlined,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (BuildContext context) {
                                            return CommentPage(
                                              itemId: item.id, // 댓글과 연결된 Item ID
                                              itemsService: itemsService, // 댓글 관리 서비스
                                            );
                                          },
                                        ).then((updatedCommentsCount) {
                                          if (updatedCommentsCount != null) {
                                            setState(() {
                                              item.commentsCount = updatedCommentsCount; // 댓글 수 갱신
                                            });
                                          }
                                        });
                                      },


                                    ),
                                    Text(
                                      '${item.commentsCount}',
                                      style: const TextStyle(
                                          fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ],
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
        );
      },
    );

  }
}