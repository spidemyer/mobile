import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/book_model.dart';
import '../viewmodels/book_provider.dart';

class ShelfList extends StatelessWidget {
  final String status;
  const ShelfList({super.key, required this.status});

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
        throw 'Não foi possível abrir o leitor';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao abrir leitor: $e')),
        );
      }
    }
  }

  void _showUpdateProgressDialog(
      BuildContext context, String userId, BookModel book) {
    final controller = TextEditingController(text: book.pagesRead.toString());
    final bookProvider = Provider.of<BookProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Atualizar Leitura\n"${book.title}"',
            style: const TextStyle(fontSize: 16, color: Color(0xFF4A148C))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total do Livro: ${book.pageCount} páginas'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Páginas que já leu',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newPages = int.tryParse(controller.text) ?? book.pagesRead;
              bookProvider.updatePagesRead(
                  userId, book.id, newPages, book.pageCount);
              Navigator.pop(ctx);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthService>(context).currentUser?.uid;
    final dbService = DatabaseService();
    final bookProvider = Provider.of<BookProvider>(context, listen: false);

    if (userId == null) {
      return const Center(child: Text("Usuário não autenticado"));
    }

    return StreamBuilder<List<BookModel>>(
      stream: dbService.getUserBooksByStatus(userId, status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6A1B9A)));
        }
        final books = snapshot.data ?? [];
        if (books.isEmpty) {
          return Center(child: Text('Nenhum livro na estante "$status"'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            final double progress = book.pageCount > 0
                ? (book.pagesRead / book.pageCount).clamp(0.0, 1.0)
                : 0.0;

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: book.thumbnailUrl != null
                          ? Image.network(book.thumbnailUrl!,
                              width: 45, fit: BoxFit.cover)
                          : const Icon(Icons.book,
                              size: 40, color: Color(0xFF8E24AA)),
                      title: Text(book.title,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        '${book.authors.join(", ")}\nProgresso: ${book.pagesRead} de ${book.pageCount} págs. (${(progress * 100).toStringAsFixed(0)}%)',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (newStatus) {
                          bookProvider.changeBookStatus(
                              userId, book.id, newStatus);
                        },
                        itemBuilder: (context) => [
                          if (status != 'Quero Ler')
                            const PopupMenuItem(
                                value: 'Quero Ler',
                                child: Text('Mover para Quero Ler')),
                          if (status != 'Lendo')
                            const PopupMenuItem(
                                value: 'Lendo', child: Text('Mover para Lendo')),
                          if (status != 'Lidos')
                            const PopupMenuItem(
                                value: 'Lidos', child: Text('Mover para Lidos')),
                        ],
                      ),
                    ),
                    if (status == 'Lendo')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: const Color(0xFFE1BEE7),
                          color: const Color(0xFF6A1B9A),
                          minHeight: 6,
                        ),
                      ),
                    const SizedBox(height: 8),
                    // BOTÕES DE AÇÃO: LER E ATUALIZAR PÁGINAS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFAB47BC),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _openBookReader(context, book.previewLink),
                          icon: const Icon(Icons.chrome_reader_mode, size: 16),
                          label: const Text('LER'),
                        ),
                        if (status == 'Lendo') ...[
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => _showUpdateProgressDialog(
                                context, userId, book),
                            icon: const Icon(Icons.edit, size: 16, color: Color(0xFF8E24AA)),
                            label: const Text('Páginas', style: TextStyle(color: Color(0xFF8E24AA))),
                          ),
                        ],
                        const SizedBox(width: 8),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}