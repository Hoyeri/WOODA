import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wooda_client/src/app.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/services.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', '');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Wooda Client',
      debugShowCheckedModeBanner: false, // 디버그 배너 제거
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xffFF5987), // 주요 색상 설정
          secondary: Color(0xffE5EBFC), // 보조 색상 설정
        ),
        fontFamily: 'Inter', // 전체 앱에 적용되는 폰트
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Color(0xffFF5987)), // 아이콘 색상
          elevation: 0, // AppBar 그림자 제거
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xffFF5987),
          foregroundColor: Colors.white,
        ),
      ),
      home: const App(), // 앱의 메인 화면 설정
    );
  }
}
