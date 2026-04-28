import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/tela_inicial.dart';
import 'providers/eco_provider.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(
    // MultiProvider permite gerenciar múltiplos estados globais ao mesmo tempo
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => EcoProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const Myapp(),
    ),
  );
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuta o ThemeProvider para saber qual tema aplicar
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'EcoTrack',
      debugShowCheckedModeBanner: false,
      
      // Agora o tema segue o que for definido no ThemeProvider
      themeMode: themeProvider.themeMode, 

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
      ),
      
      home: TelaInicial(),
    );
  }
}