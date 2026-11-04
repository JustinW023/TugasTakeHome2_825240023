import 'package:flutter/material.dart';
import 'pages/musicplayer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '825240023 - Tugas Mobile Programming 2',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const MusicPlayerPage(),
    );
  }
}