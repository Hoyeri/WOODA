import 'package:flutter/material.dart';
import 'package:wooda_client/src/components/image_data.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: Scaffold(
          appBar: AppBar(),
          body: Container(),
          bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: true,
              showUnselectedLabels: false,
              items: [
                BottomNavigationBarItem(
                  icon: ImageData(IconsPath.homeOff),
                  activeIcon: ImageData(IconsPath.homeOn),
                  label: '모아 보기',
                ),
                  BottomNavigationBarItem(
                  icon: ImageData(IconsPath.diaryOff),
                  activeIcon: ImageData(IconsPath.diaryOn),
                  label: '나의 일상',
                ),
                  BottomNavigationBarItem(
                  icon: ImageData(IconsPath.friendsOff),
                  activeIcon: ImageData(IconsPath.friendsOn),
                  label: '친구들',
                ),
              ],
            selectedItemColor: const Color(0xffFF5987),
          ),
        ),
    );
  }
}