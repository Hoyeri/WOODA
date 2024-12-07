import 'package:flutter/material.dart';
import 'package:get/get.dart';


class ImageData extends StatelessWidget {
  final String icon;
  final double? width;
  ImageData(
      this.icon, {
        super.key,
        this.width = 55,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      icon,
      width: width! / Get.mediaQuery.devicePixelRatio,
    );
  }
}

class IconsPath {
  static String get homeOff => 'assets/images/home_off.png';
  static String get homeOn => 'assets/images/home_on.png';
  static String get diaryOff => 'assets/images/diary_off.png';
  static String get diaryOn => 'assets/images/diary_on.png';
  static String get friendsOff => 'assets/images/friends_off.png';
  static String get friendsOn => 'assets/images/friends_on.png';
}