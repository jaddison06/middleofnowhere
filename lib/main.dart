import 'package:flutter/material.dart';
import 'src/mainpage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'middle of nowhere',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 42, 25, 1), brightness: Brightness.dark),
        useMaterial3: true
      ),
      home: const MainPage(),
    );
  }
}