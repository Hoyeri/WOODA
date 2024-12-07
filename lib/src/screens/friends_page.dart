import 'package:flutter/material.dart';
import 'package:wooda_client/src/models/friends_model.dart';
import 'package:wooda_client/src/components/image_data.dart';
import 'package:wooda_client/src/services/friends_service.dart';
import 'package:wooda_client/src/screens/app_screen.dart';
import 'package:wooda_client/src/services/items_service.dart';
import 'package:wooda_client/src/screens/all_items_page.dart';
import 'package:wooda_client/src/services/api_client_singleton.dart';

class FriendsPage extends StatefulWidget {
  final Future<List<Friend>> friends;
  final Future<void> Function(String username) onSubscribe;

  const FriendsPage({
    super.key,
    required this.friends,
    required this.onSubscribe,
  });

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List<Friend> friends = [];
  final ItemsService _itemsService = ItemsService(apiClient);
  final FriendsService _friendsService = FriendsService(apiClient); // FriendsService 추가
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    _fetchFriends();
  }

  void _fetchFriends() async {
    try {
      final fetchedFriends = await widget.friends;
      setState(() {
        friends = fetchedFriends;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("친구 목록 가져오기 실패: $e")),
      );
    }
  }

  void _showAddFriendDialog(BuildContext context) {
    String username = "";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("친구 추가"),
          content: TextField(
            decoration: const InputDecoration(hintText: "사용자 이름을 입력하세요"),
            onChanged: (value) {
              username = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // 다이얼로그 닫기
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () async {
                if (username.isNotEmpty) {
                  try {
                    // FriendsService의 addFriend 호출
                    await _friendsService.addFriend(username);

                    Navigator.of(context).pop(); // 다이얼로그 닫기
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(content: Text("$username님이 추가되었습니다!")),
                    );

                    // 친구 목록 갱신
                    _fetchFriends();
                  } catch (e) {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(content: Text("친구 추가 실패: $e")),
                    );
                  }
                }
              },
              child: const Text("추가"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "친구 목록",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              _showAddFriendDialog(context); // 친구 추가 다이얼로그 호출
            },
            icon: const Icon(
              Icons.person_add,
              color: Colors.black, // 아이콘 색상 조정
              size: 24, // 아이콘 크기 조정
            ),
            tooltip: "친구 추가", // 접근성 및 툴팁 추가
          ),
          SizedBox(width: 20)
        ],
      ),
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_04.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          // 친구 목록 UI
          friends.isEmpty
              ? Center(
            child: const Text(
              "친구 목록이 비어 있습니다.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage(
                        'assets/images/profile_default.png'),
                  ),
                  title: Text(
                    friend.userName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text(
                    "상태 메시지가 없습니다.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        backgroundColor: Colors.white,
        currentIndex: _currentIndex, // 디폴트 버튼 == '나의 일상'
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
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AppScreen(),
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
