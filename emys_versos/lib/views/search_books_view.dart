import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../viewmodels/book_provider.dart';
import '../services/auth_service.dart';
import '../models/book_model.dart';

class SearchBooksView extends StatelessWidget {
  const SearchBooksView({super.key});

  // Função para abrir o leitor/link do livro
  Future<void> _openBookReader(BuildContext context, String? url) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prévia de leitura indisponível para este livro.')),
      );
      return;
    }

    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Não foi possível abrir a URL';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao abrir leitor: $e')),
        );
      }
    }
  }

  void _showAddToShelfDialog(BuildContext context, BookModel book) {
    final userId = Provider.of<AuthService>(context, listen: false).currentUser?.uid;
    final bookProvider = Provider.of<BookProvider>(context, listen: false);

    if (userId == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Adicionar "${book.title}"',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A148C)),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.bookmark_border, color: Color(0xFF8E24AA)),
                title: const Text('Quero Ler'),
                onTap: () {
                  bookProvider.addBookToShelf(userId, book, 'Quero Ler');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.book, color: Color(0xFF8E24AA)),
                title: const Text('Lendo'),
                onTap: () {
                  bookProvider.addBookToShelf(userId, book, 'Lendo');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle, color: Color(0xFF8E24AA)),
                title: const Text('Lidos'),
                onTap: () {
                  bookProvider.addBookToShelf(userId, book, 'Lidos');
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por título ou autor...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF6A1B9A)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (query) => bookProvider.searchBooks(query),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: bookProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6A1B9A)))
                : ListView.builder(
                    itemCount: bookProvider.searchResults.length,
                    itemBuilder: (context, index) {
                      final book = bookProvider.searchResults[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Colors.white,
                        surfaceTintColor: const Color(0xFFE1BEE7),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              ListTile(
                                leading: book.thumbnailUrl != null
                                    ? Image.network(book.thumbnailUrl!, width: 45, fit: BoxFit.cover)
                                    : const Icon(Icons.book, size: 40, color: Color(0xFFAB47BC)),
                                title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${book.authors.join(", ")}\n${book.pageCount} páginas'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.add_circle, color: Color(0xFF6A1B9A), size: 28),
                                  onPressed: () => _showAddToShelfDialog(context, book),
                                ),
                              ),
                              // BOTÃO DE LER EMBAIXO DE CADA LIVRO
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFAB47BC), // Lilás destacado
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () => _openBookReader(context, book.previewLink),
                                    icon: const Icon(Icons.chrome_reader_mode, size: 18),
                                    label: const Text('LER', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}