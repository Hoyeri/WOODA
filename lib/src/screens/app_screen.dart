import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wooda_client/src/components/image_data.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wooda_client/src/screens/all_items_page.dart';
import 'package:wooda_client/src/screens/detail_page.dart';
import 'package:wooda_client/src/models/detail_page_model.dart';
import 'package:wooda_client/src/screens/date_time_selection_page.dart';
import 'package:wooda_client/src/screens/add_schedule_page.dart';
import 'package:wooda_client/src/services/items_service.dart';
import 'package:wooda_client/src/services/auth_service.dart';
import 'package:wooda_client/src/services/friends_service.dart';
import 'package:wooda_client/src/screens/friends_page.dart';
import 'package:wooda_client/src/models/items_model.dart';
import 'package:wooda_client/src/services/api_client_singleton.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  final ItemsService _itemsService = ItemsService(apiClient);
  final FriendsService _friendsService = FriendsService(apiClient); // FriendsService 추가
  CalendarFormat format = CalendarFormat.week;
  int _currentIndex = 1;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  List<dynamic> items = [];
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadItems(selectedDay);
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    try {
      final id = await AuthService(apiClient).getId(); // AuthService의 getId 호출
      setState(() {
        currentUserId = id; // 현재 사용자 ID 저장
      });
      _loadItems(selectedDay); // 사용자 ID 로드 후 항목 불러오기
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("사용자 ID 로드 실패: $e")),
      );
    }
  }

  Future<void> _loadItems(DateTime selectedDate) async {
    try {
      final data = await _itemsService.getItemsByDate(selectedDate);

      // 사용자 ID와 선택된 날짜를 기준으로 항목 필터링
      setState(() {
        items = data.where((item) {
          final itemDate = DateTime(
            item.date.year,
            item.date.month,
            item.date.day,
          );
          final selectedDateOnly = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
          );

          _loadCurrentUserId();

          return item.user_id == currentUserId && itemDate == selectedDateOnly;
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading items: $e")),
      );
    }
  }


  Future<void> _updateItem(Item updatedItem) async {
    try {
      final result = await _itemsService.updateItem(updatedItem);
      if (result['status'] == 'success') {
        // 성공 시 UI 갱신
        await _loadItems(selectedDay);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item updated successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating item: ${result['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _deleteItem(int itemId) async {
    try {
      final result = await _itemsService.deleteItem(itemId);
      if (result['status'] == 'success') {
        // 삭제 성공 시, 데이터 재갱신
        await _loadItems(selectedDay);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item deleted successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error deleting item: ${result['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<void> _addItem() async {
    final dateTimeResult = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DateTimeSelectionPage()),
    );

    if (dateTimeResult != null && dateTimeResult is Map<String, dynamic>) {
      final itemResult = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddItemPage(dateTime: selectedDay)),
      );

      if (itemResult != null) {
        try {
          final response = await _itemsService.createItem(
            type: itemResult['type'],
            title: itemResult['title'],
            description: itemResult['description'],
            date: selectedDay.toIso8601String(),
            image: itemResult['image'],
          );

          if (response['status'] == 'success') {
            // 데이터 갱신 강제 호출
            await _loadItems(selectedDay);

            // 데이터 반영 확인용 디버깅 로그
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Item added successfully")),
            );
          } else {
            throw Exception(response['message']);
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error adding item: $e")),
          );
        }
      }
    }
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                _loadItems(selectedDay);
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
          await _addItem();
          await _loadItems(selectedDay); // 데이터 갱신 강제 호출
        },
        backgroundColor: const Color(0xffFF5987),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: Icon(Icons.add),
      ),
      body: items.isEmpty
          ? const Center(
        child: Text('작성된 일정/일기가 없습니다. + 버튼으로 추가하세요!'),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final bool isDiary = item.type == "diary";

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailPage(
                      itemsService: _itemsService,
                      item: item,
                      model: DetailPageModel(
                        id: item.id,
                        title: item.title,
                        description: item.description,
                        date: item.date,
                        image: item.image,
                      ),
                      onUpdate: (updatedItem) async {
                        await _updateItem(updatedItem);
                        setState(() {});
                      },
                      onDelete: () async {
                        await _deleteItem(item.id);
                        setState(() {});
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
                              Flexible(
                                child: Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis, // 텍스트 넘침 처리
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(width: 4), // 간격을 줄이거나 제거
                              Text(
                                "${item.date.hour}:${item.date.minute.toString().padLeft(2, '0')}",
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          // 내용
                          Text(
                            item.description,
                            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 이미지 미리보기
                    // 이미지 미리보기
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: (item.image != null && item.image!.isNotEmpty)
                          ? Image.file(
                        File(item.image!), // File 객체를 생성하여 Image.file로 로드
                        width: 80, // 이미지 폭
                        height: 90, // 카드의 전체 높이에 맞춤
                        fit: BoxFit.cover,
                      )
                          : SizedBox(width: 80, height: 90), // 기본 크기 설정
                    ),

                  ],
                ),
              ),
            ),
          );
        },
      ),
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
                builder: (context) => AllItemsPage(
                  items: _itemsService.getItems(),
                  onUpdate: _itemsService.updateItem,
                  onDelete: _itemsService.deleteItem,
                ),
              ),
            );
          } else if (index == 2) {
            // 친구들로 이동
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FriendsPage(
                  friends: _friendsService.getFriends(), // 실제 사용자 ID 사용
                  onSubscribe: (username) async {
                    await _friendsService.addFriend(username);
                  },
                ),
              ),
            );
          } else {
            // 현재 페이지 (나의 일상) 유지
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
    );
  }
}