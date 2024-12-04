///all_shedules_page.dart
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wooda_client/src/components/image_data.dart';
import 'package:wooda_client/src/app.dart';
import 'package:wooda_client/src/models/detail_page_model.dart';
import 'package:wooda_client/src/models/schedule_model.dart';
import 'package:wooda_client/src/screens/detail_page.dart';
import 'package:wooda_client/src/screens/comment_page.dart';

class AllSchedulesPage extends StatefulWidget {
  final List<Schedule> schedules;
  final void Function(int id) onDelete; // 삭제 함수
  final void Function(Schedule updatedSchedule) onUpdate;

  const AllSchedulesPage({
    super.key,
    required this.schedules,
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

  List<Schedule> getSchedulesForCurrentWeek() {
    return widget.schedules
        .where((schedule) =>
    schedule.date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
        schedule.date.isBefore(_endDate.add(const Duration(days: 1))))
        .toList();
  }

  void toggleLike(Schedule schedule) {
    setState(() {
      const currentUserId = "user123";

      if (userLikes[schedule.id]?.contains(currentUserId) ?? false) {
        userLikes[schedule.id]?.remove(currentUserId);
        schedule.likes--;
      } else {
        userLikes.putIfAbsent(schedule.id, () => {});
        userLikes[schedule.id]!.add(currentUserId);
        schedule.likes++;
      }
    });
  }

  List<Schedule> getFilteredAndSortedSchedules(String type) {
    final filteredSchedules = widget.schedules
        .where((schedule) => schedule.type == type)
        .toList();
    // "diary"일 경우 최신순 정렬, "schedule"일 경우 오래된 순 정렬
    filteredSchedules.sort((a, b) => type == "diary"
        ? b.date.compareTo(a.date) // 최신순 정렬
        : a.date.compareTo(b.date)); // 오래된 순 정렬
    return filteredSchedules;
  }

  @override
  Widget build(BuildContext context) {
    final schedulesByDay = List.generate(7, (index) {
      final day = _startDate.add(Duration(days: index));
      final daySchedules = widget.schedules
          .where((schedule) => schedule.date.day == day.day && schedule.date.month == day.month && schedule.date.year == day.year)
          .toList();
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
              Column(
                children: [
                  // 주간 선택 바
                  Container(
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
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(7, (index) {
                          final day = _startDate.add(Duration(days: index));
                          final daySchedules = widget.schedules
                              .where((schedule) =>
                          schedule.type == "schedule" &&
                              schedule.date.year == day.year &&
                              schedule.date.month == day.month &&
                              schedule.date.day == day.day)
                              .toList();

                          return Container(
                            padding: EdgeInsets.only(left: 20),
                            width: 180, // 하루 일정 열의 폭 설정
                            margin: const EdgeInsets.only(right: 8.0), // 열 간 간격
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
                                    : Expanded(
                                  child: ListView.builder(
                                    itemCount: daySchedules.length,
                                    itemBuilder: (context, index) {
                                      final schedule = daySchedules[index];
                                      return GestureDetector(
                                        onTap: () {
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
                                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            elevation: 10.0,
                                            child: SizedBox(
                                              width: 160,
                                              height: 120,
                                              child: Column(
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Column(
                                                            children: [
                                                              CircleAvatar(
                                                                radius: 13,
                                                                backgroundImage: AssetImage(
                                                                    'assets/images/profile_default.png'),
                                                              ),
                                                              const SizedBox(height: 4),
                                                              Text(
                                                                schedule.writer,
                                                                style: const TextStyle(
                                                                  fontSize: 9,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment.start,
                                                              children: [
                                                                SizedBox(height: 4),
                                                                Text(
                                                                  schedule.title,
                                                                  style: const TextStyle(
                                                                    fontSize: 13,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                                SizedBox(height: 2),
                                                                Align(
                                                                  alignment: Alignment.topLeft,
                                                                  child: Text(
                                                                    DateFormat('HH:mm')
                                                                        .format(schedule.date),
                                                                    style: const TextStyle(
                                                                      fontSize: 12,
                                                                      color: Colors.grey,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Container(
                                                      alignment: Alignment.topLeft,
                                                      width: double.infinity,
                                                      padding: const EdgeInsets.only(
                                                          left: 10, right: 10, top: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: const BorderRadius.only(
                                                          bottomLeft: Radius.circular(20),
                                                          bottomRight: Radius.circular(20),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        schedule.description,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              )


            else if (_selectedTabIndex == 2) // "일기" 탭
              ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: getFilteredAndSortedSchedules("diary").length,
                itemBuilder: (context, index) {
                  final diary = getFilteredAndSortedSchedules("diary")[index];
                  final isLiked = userLikes[diary.id]?.contains("user123") ?? false;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(
                            schedule: diary,
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
                                diary.writer,
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
                              borderRadius: BorderRadius.circular(20)
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
                                      "${diary.date.year}/${diary.date.month.toString().padLeft(2, '0')}/${diary.date.day.toString().padLeft(2, '0')}",
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // 제목
                                  Text(
                                    diary.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  // 내용
                                  Text(
                                    diary.description,
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
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 좋아요와 댓글을 정렬
                                    children: [
                                      // 좋아요 수와 아이콘
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              isLiked ? Icons.favorite : Icons.favorite_border,
                                              color: Colors.red,
                                            ),
                                            onPressed: () => toggleLike(diary),
                                          ),
                                          Text(
                                            '${diary.likes}', // 좋아요 수
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      // 댓글 수와 아이콘
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.comment_outlined, color: Colors.grey),
                                            onPressed: () {
                                              scheduleComments.putIfAbsent(diary.id, () => []); // 댓글 초기화
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                backgroundColor: Colors.transparent,
                                                builder: (context) {
                                                  return CommentPage(
                                                    initialComments: scheduleComments[diary.id]!,
                                                    onCommentsUpdated: (updatedComments) {
                                                      setState(() {
                                                        scheduleComments[diary.id] = updatedComments;
                                                      });
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                          Text(
                                            '${scheduleComments[diary.id]?.length ?? 0}', // 댓글 수
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
