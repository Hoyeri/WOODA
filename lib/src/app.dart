import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wooda_client/src/screens/sign_up_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent
    ));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wooda Client',
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SignUpPage(),
    );
  }
}
