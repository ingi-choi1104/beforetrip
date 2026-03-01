import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const BeforeTripApp());
}

class BeforeTripApp extends StatelessWidget {
  const BeforeTripApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '여행 가기 전',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0277BD),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
