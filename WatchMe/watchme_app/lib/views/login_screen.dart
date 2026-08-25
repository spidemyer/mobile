import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _emailController = TextEditingController();

  void _handleLogin() async {
    final username = _userController.text.trim();
    final email = _emailController.text.trim();

    if (username.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha os dados de acesso.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUser', username);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(username: username)),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: Icon(isDark ? Icons.nightlight_round : Icons.wb_sunny),
                    onPressed: () => themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Entrar', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const Text('Bem-vindo de volta!', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              const Text('NOME DE USUÁRIO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _userController,
                decoration: const InputDecoration(hintText: 'Seu usuário'),
              ),
              const SizedBox(height: 16),
              const Text('E-MAIL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(hintText: 'seu@email.com'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  child: const Text('Entrar', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}