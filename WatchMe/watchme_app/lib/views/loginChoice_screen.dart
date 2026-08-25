import 'package:flutter/material.dart';
import '../main.dart';
import 'register_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class LoginChoiceScreen extends StatelessWidget {
  const LoginChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Botão de alternar tema no topo direito
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(isDark ? Icons.nightlight_round : Icons.wb_sunny),
                  onPressed: () {
                    themeNotifier.value =
                        isDark ? ThemeMode.light : ThemeMode.dark;
                  },
                ),
              ),
              const Spacer(),
              // Imagem da aplicação
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'views/imgs/gemini.svg.png',
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(Icons.movie_outlined, size: 50, color: Colors.white),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'WatchMe',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Seu diário de filmes',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const Spacer(),
              // Botão Criar uma conta
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text('Criar uma conta', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              // Botão Usar sem login
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).colorScheme.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(username: 'Visitante'),
                      ),
                    );
                  },
                  child: Text(
                    'Usar sem login',
                    style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Link para Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Já tem um perfil? '),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: Text(
                      'Acesse aqui.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}