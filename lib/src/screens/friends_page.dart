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

  void _removeFriend(String username) async {
    try {
      await _friendsService.removeFriend(username); // 친구 삭제 호출
      setState(() {
        friends.removeWhere((friend) => friend.userName == username);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$username님을 삭제했습니다!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("친구 삭제 실패: $e")),
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
                    await _friendsService.addFriend(username);
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(content: Text("$username님이 추가되었습니다!")),
                    );
                    final updatedFriends = await _friendsService.getFriends();
                    setState(() {
                      friends = updatedFriends; // UI 갱신을 위해 상태 업데이트
                    }); // 친구 목록 갱신
                  } catch (e) {
                    Navigator.of(context).pop();
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
              _showAddFriendDialog(context);
              setState(() {
              });
            },
            icon: const Icon(
              Icons.person_add,
              color: Colors.black,
              size: 24,
            ),
            tooltip: "친구 추가",
          ),
          SizedBox(width: 20)
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_04.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
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
                    backgroundImage:
                    AssetImage('assets/images/profile_default.png'),
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
                  trailing: ElevatedButton(
                    onPressed: () {
                      _removeFriend(friend.userName); // 친구 삭제 호출
                      setState(() {
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffFF5987), // 기존 구독 버튼 색상
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // 둥근 테두리
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), // 버튼 안쪽 여백
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // 버튼 크기를 텍스트와 아이콘에 맞게 조절
                      children: const [
                        Text(
                          "삭제",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.delete_forever, // 삭제 아이콘
                          size: 18,
                          color: Colors.white,
                        ),
                      ],
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
        currentIndex: _currentIndex,
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FriendsPage(
                  friends: _friendsService.getFriends(),
                  onSubscribe: (username) async {
                    await _friendsService.addFriend(username);
                  },
                ),
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
    );
  }
}
