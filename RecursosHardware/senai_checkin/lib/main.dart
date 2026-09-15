import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SenaiCheckInApp());
}

class SenaiCheckInApp extends StatelessWidget {
  const SenaiCheckInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SENAI CheckIn',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}