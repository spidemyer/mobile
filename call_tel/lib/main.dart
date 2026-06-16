import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controller/contact_controller.dart';
import 'views/home_view.dart';

void main() { //ponto de entrada do aplicativo, onde o estado do tema e dos contatos é gerenciado usando o Provider
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ContactController()),
      ],
      child: const CallTelApp(),
    ),
  );
}

class CallTelApp extends StatelessWidget { //widget principal do app
  const CallTelApp({super.key});

  @override
  Widget build(BuildContext context) { //interface do aplicativo
    final controller = context.watch<ContactController>();

    return MaterialApp( //tela principal do aplicativo (usei a IA para estilizar melhor e otimizar o tempo)
      title: 'Call Tel',
      debugShowCheckedModeBanner: false,
      themeMode: controller.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C3AED),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F8FF),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C3AED),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}