import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watchme_app/views/loginChoice_screen.dart';
import 'views/loginChoice_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WatchMeApp());
}

// ValueNotifier global para gerenciar o modo Claro/Escuro em tempo real
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

class WatchMeApp extends StatelessWidget {
  const WatchMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, __) {
        return MaterialApp(
          title: 'WatchMe',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,

          // MODO CLARO (Fundo Azul Claro, Botões Roxo Intenso)
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFE0F2FE),
            primaryColor: const Color(0xFF7B1FA2),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7B1FA2),
              surface: Color(0xFFF1F5F9),
              onSurface: Colors.black,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFFCBD5E1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintStyle: const TextStyle(color: Colors.black54),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B1FA2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          // MODO ESCURO (Fundo Azul Escuro, Botões Roxo Claro)
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF101F29),
            primaryColor: const Color(0xFF8B5CF6),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF8B5CF6),
              surface: Color(0xFF1E293B),
              onSurface: Colors.white,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF1B2A36),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintStyle: const TextStyle(color: Colors.white38),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          home: const LoginChoiceScreen(),
        );
      },
    );
  }
}