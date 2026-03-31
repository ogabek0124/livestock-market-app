import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'features/home/home_screen.dart';

void main() {
  runApp(LivestockApp());
}

class LivestockApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Livestock Market',
      themeMode: ThemeMode.system, // Supports switching between Light and Dark natively
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          color: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: Color(0xFF121212),
        appBarTheme: AppBarTheme(
          color: Color(0xFF1E1E1E),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        cardTheme: CardTheme(
          color: Color(0xFF1E1E1E),
        ),
      ),
      home: HomeScreen(),
    );
  }
}
