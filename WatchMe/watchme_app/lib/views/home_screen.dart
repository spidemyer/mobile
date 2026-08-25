import 'package:flutter/material.dart';
import 'package:watchme_app/views/loginChoice_screen.dart';
import '../models/movie.dart';
import '../models/review.dart';
import '../services/tmdb_service.dart';
import '../services/database_helper.dart';
import '../main.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Movie> _movies = [];
  Set<int> _favoriteIds = {};
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final movies = await TmdbService.getPopularMovies();
    final favs = await DatabaseHelper.instance.getFavorites(widget.username);

    setState(() {
      _movies = movies;
      _favoriteIds = favs.map((m) => m.id).toSet();
      _isLoading = false;
    });
  }

  void _onSearch(String query) async {
    setState(() => _isLoading = true);
    final results = await TmdbService.searchMovies(query);
    setState(() {
      _movies = results;
      _isLoading = false;
    });
  }

  // Verifica se o usuário atual é visitante
  bool _checkIsGuestAndAlert(String action) {
    final isGuest = widget.username.isEmpty ||
        widget.username.toLowerCase() == 'visitante' ||
        widget.username.toLowerCase() == 'guest';

    if (isGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Faça login ou crie uma conta para $action!'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Entrar',
            textColor: Colors.amber,
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginChoiceScreen()),
                (route) => false,
              );
            },
          ),
        ),
      );
      return true;
    }
    return false;
  }

  void _toggleFavorite(Movie movie) async {
    if (_checkIsGuestAndAlert('salvar favoritos')) return;

    if (_favoriteIds.contains(movie.id)) {
      await DatabaseHelper.instance.removeFavorite(movie.id, widget.username);
      setState(() => _favoriteIds.remove(movie.id));
    } else {
      await DatabaseHelper.instance.addFavorite(movie, widget.username);
      setState(() => _favoriteIds.add(movie.id));
    }
  }

  void _showRatingModal(Movie movie) {
    if (_checkIsGuestAndAlert('avaliar filmes')) return;

    double selectedRating = 5.0;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Avaliar "${movie.title}"', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < selectedRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () => setModalState(() => selectedRating = index + 1.0),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(hintText: 'Escreva sua avaliação...'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        final review = Review(
                          movieId: movie.id,
                          movieTitle: movie.title,
                          posterPath: movie.posterPath,
                          rating: selectedRating,
                          comment: commentController.text,
                          userId: widget.username,
                        );
                        await DatabaseHelper.instance.addReview(review);
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Avaliação salva com sucesso!')),
                          );
                        }
                      },
                      child: const Text('Salvar Avaliação'),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_outlined, color: Colors.white38, size: 32),
            SizedBox(height: 6),
            Text(
              'Sem Imagem',
              style: TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho da Home
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Olá, ${widget.username} 👋', style: const TextStyle(color: Colors.grey)),
                      const Text('Explorar Filmes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(isDark ? Icons.nightlight_round : Icons.wb_sunny),
                        onPressed: () => themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark,
                      ),
                      IconButton(
                        icon: const Icon(Icons.person_outline),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfileScreen(username: widget.username),
                            ),
                          );
                        },
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 16),
              // Campo de Busca
              TextField(
                controller: _searchController,
                onSubmitted: _onSearch,
                decoration: InputDecoration(
                  hintText: 'Pesquisar filme...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _onSearch('');
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Galeria de Filmes em Grid
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        itemCount: _movies.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.55,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) {
                          final movie = _movies[index];
                          final isFav = _favoriteIds.contains(movie.id);
                          final imageUrl = TmdbService.getImageUrl(movie.posterPath);

                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Theme.of(context).colorScheme.surface,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Poster + Ícone de Favorito
                                Expanded(
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                        child: imageUrl.isNotEmpty
                                            ? Image.network(
                                                imageUrl,
                                                width: double.infinity,
                                                height: double.infinity,
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child, loadingProgress) {
                                                  if (loadingProgress == null) return child;
                                                  return const Center(
                                                    child: CircularProgressIndicator(strokeWidth: 2),
                                                  );
                                                },
                                                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                                              )
                                            : _buildPlaceholder(),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () => _toggleFavorite(movie),
                                          child: CircleAvatar(
                                            backgroundColor: Colors.black54,
                                            radius: 14,
                                            child: Icon(
                                              Icons.outlined_flag,
                                              size: 16,
                                              color: isFav ? Colors.red : Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                // Nome do Filme + Opções (...)
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          movie.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => _showRatingModal(movie),
                                        child: const Icon(Icons.more_vert, size: 16),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}