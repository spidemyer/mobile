import 'package:flutter/material.dart';
import 'views/home_page.dart';

void main() {
  runApp(const MeuApp());
}
// Classe principal do aplicativo
class MeuApp extends StatelessWidget {
  const MeuApp({Key? key}) : super(key: key);

  // Constrói o widget principal do aplicativo
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Produtos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          primary: Colors.deepPurple,
          secondary: Colors.purpleAccent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const HomePage(),
    );
  }
}