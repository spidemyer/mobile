import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

// View para exibir as estatísticas do usuário, como livros lidos e páginas lidas
class StatsView extends StatelessWidget {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthService>(context).currentUser?.uid;
    final dbService = DatabaseService();

    if (userId == null) {
      return const Center(child: Text("Usuário não autenticado"));
    }

    return StreamBuilder<Map<String, dynamic>>(
      stream: dbService.getUserStats(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Não foi possível carregar as estatísticas.'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF6A1B9A)),
          );
        }

        final stats = snapshot.data;
        final livrosLidos = (stats?['livrosLidos'] as num?)?.toInt() ?? 0;
        final paginasLidas = (stats?['paginasLidas'] as num?)?.toInt() ?? 0;

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Minhas Estatísticas',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A148C),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildStatCard(
                icon: Icons.menu_book,
                title: 'Livros Lidos',
                value: '$livrosLidos',
                color: const Color(0xFF8E24AA),
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                icon: Icons.auto_stories,
                title: 'Páginas Lidas',
                value: '$paginasLidas',
                color: const Color(0xFFAB47BC),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
