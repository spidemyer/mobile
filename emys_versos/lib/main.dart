import 'package:emys_versos/views/login_view.dart';
import 'package:emys_versos/views/main_navigation_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'viewmodels/book_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<BookProvider>(create: (_) => BookProvider()),
      ],
      child: const EmysVersosApp(),
    ),
  );
}

class EmysVersosApp extends StatelessWidget {
  const EmysVersosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Emy's Versos",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6A1B9A), // Roxo principal
          primary: const Color(0xFF6A1B9A),
          secondary: const Color(0xFFAB47BC), // Lilás
          tertiary: const Color(0xFFE1BEE7), // Lilás claro
          surface: const Color(0xFFF3E5F5), // Fundo suave
        ),
        scaffoldBackgroundColor: const Color(0xFFFBF7FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6A1B9A),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6A1B9A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

// Widget responsável por redirecionar entre Login e App Principal
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF6A1B9A)),
            ),
          );
        }
        if (snapshot.hasData) {
          return const MainNavigationView();
        }
        return const LoginView();
      },
    );
  }
}
