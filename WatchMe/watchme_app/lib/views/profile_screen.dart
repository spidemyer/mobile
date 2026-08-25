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
// Tela de perfil do usuário, exibindo informações, avaliações e favoritos
class _ProfileScreenState extends State<ProfileScreen> {
  List<Movie> _favorites = [];
  List<Review> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }
// Carrega os dados do perfil do usuário, incluindo favoritos e avaliações
  Future<void> _loadProfileData() async {
    final favs = await DatabaseHelper.instance.getFavorites(widget.username);
    final revs = await DatabaseHelper.instance.getReviews(widget.username);

    setState(() {
      _favorites = favs;
      _reviews = revs;
    });
  }
// Método para lidar com o logout do usuário, removendo o usuário atual das preferências compartilhadas e redirecionando para a tela de escolha de login
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
// Método para remover um filme dos favoritos do usuário, atualizando a lista de favoritos e exibindo uma mensagem de confirmação
  Future<void> _removeFavorite(int movieId) async {
    await DatabaseHelper.instance.removeFavorite(movieId, widget.username);
    _loadProfileData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Filme removido dos favoritos!')),
      );
    }
  }

  Future<void> _deleteReview(int reviewId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Avaliação'),
        content: const Text('Tem certeza que deseja excluir esta avaliação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      await DatabaseHelper.instance.deleteReview(reviewId);
      _loadProfileData();
      messenger.showSnackBar(
        const SnackBar(content: Text('Avaliação excluída com sucesso!')),
      );
    }
  }
// Método para editar a avaliação do filme, deixando editar a pontuação e o comentário
  Future<void> _showEditReviewDialog(Review review) async {
    final commentController = TextEditingController(text: review.comment);
    double rating = review.rating;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Editar: ${review.movieTitle}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Nota: ${rating.toStringAsFixed(1)} ⭐'),
              Slider(
                value: rating,
                min: 0,
                max: 5,
                divisions: 10,
                label: rating.toStringAsFixed(1),
                onChanged: (val) {
                  setDialogState(() {
                    rating = val;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: 'Comentário',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(ctx);
                final messenger = ScaffoldMessenger.of(context);

                final updatedReview = Review(
                  id: review.id,
                  username: review.username,
                  movieId: review.movieId,
                  movieTitle: review.movieTitle,
                  posterPath: review.posterPath,
                  rating: rating,
                  comment: commentController.text, userId: '',
                );

                await DatabaseHelper.instance.updateReview(updatedReview);
                _loadProfileData();

                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Avaliação atualizada!')),
                );
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
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

  Widget _buildMiniPlaceholder() {
    return Container(
      width: 45,
      height: 65,
      color: Colors.white10,
      child: const Icon(Icons.movie, size: 20, color: Colors.white38),
    );
  }
//estilização de widget feita com IA para otimizar o tempo.
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
                          final posterUrl = TmdbService.getImageUrl(rev.posterPath);

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 4),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: posterUrl.isNotEmpty
                                  ? Image.network(
                                      posterUrl,
                                      width: 45,
                                      height: 65,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => _buildMiniPlaceholder(),
                                    )
                                  : _buildMiniPlaceholder(),
                            ),
                            title: Text(rev.movieTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(rev.comment),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('⭐ ${rev.rating.toStringAsFixed(1)}'),
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showEditReviewDialog(rev);
                                    } else if (value == 'delete' && rev.id != null) {
                                      _deleteReview(rev.id!);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 20),
                                          SizedBox(width: 8),
                                          Text('Editar'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.red, size: 20),
                                          SizedBox(width: 8),
                                          Text('Excluir', style: TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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