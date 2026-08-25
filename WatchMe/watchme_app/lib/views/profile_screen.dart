import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watchme_app/views/loginChoice_screen.dart';
import '../models/movie.dart';
import '../models/review.dart';
import '../services/database_helper.dart';
import '../services/tmdb_service.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  final String username;

  const ProfileScreen({super.key, required this.username});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Movie> _favorites = [];
  List<Review> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final favs = await DatabaseHelper.instance.getFavorites(widget.username);
    final revs = await DatabaseHelper.instance.getReviews(widget.username);

    setState(() {
      _favorites = favs;
      _reviews = revs;
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginChoiceScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _removeFavorite(int movieId) async {
    await DatabaseHelper.instance.removeFavorite(movieId, widget.username);
    _loadProfileData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Filme removido dos favoritos!')),
      );
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 70,
      height: 100,
      color: Colors.white10,
      child: const Center(
        child: Icon(Icons.movie_outlined, color: Colors.white38, size: 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initialLetter = widget.username.isNotEmpty ? widget.username[0].toUpperCase() : 'V';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Cabeçalho
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text('Meu Perfil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(isDark ? Icons.nightlight_round : Icons.wb_sunny),
                    onPressed: () => themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Avatar do usuário
              CircleAvatar(
                radius: 40,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  initialLetter,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Text(widget.username, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              // Contadores
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text('${_reviews.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Text('Avaliações', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(width: 40),
                  Column(
                    children: [
                      Text('${_favorites.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Text('Favoritos', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Seção Minhas Avaliações
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('MINHAS AVALIAÇÕES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _reviews.isEmpty
                    ? const Center(child: Text('Nenhuma avaliação ainda'))
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _reviews.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final rev = _reviews[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(rev.movieTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(rev.comment),
                            trailing: Text('⭐ ${rev.rating.toStringAsFixed(1)}'),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 24),
              // Seção Favoritos
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('FAVORITOS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _favorites.isEmpty
                    ? const Center(child: Text('Nenhum favorito ainda'))
                    : SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _favorites.length,
                          itemBuilder: (context, index) {
                            final fav = _favorites[index];
                            final imageUrl = TmdbService.getImageUrl(fav.posterPath);

                            return Container(
                              margin: const EdgeInsets.only(right: 10),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: imageUrl.isNotEmpty
                                        ? Image.network(
                                            imageUrl,
                                            width: 70,
                                            height: 100,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                                          )
                                        : _buildPlaceholder(),
                                  ),
                                  // Botão no canto da imagem para remover dos favoritos
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeFavorite(fav.id),
                                      child: const CircleAvatar(
                                        backgroundColor: Colors.black87,
                                        radius: 11,
                                        child: Icon(Icons.close, color: Colors.white, size: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ),
              const SizedBox(height: 32),
              // Botão Sair da Conta
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text(
                    'Sair da Conta',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}