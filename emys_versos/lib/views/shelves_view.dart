import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/book_model.dart';
import '../viewmodels/book_provider.dart';
// View para gerenciar as estantes do usuário (Quero Ler, Lendo, Lidos)
class ShelvesView extends StatelessWidget {
  const ShelvesView({super.key});
  // Função para abrir o leitor/link do livro
  void _showAddCustomBookModal(BuildContext context) {
    final userId = Provider.of<AuthService>(context, listen: false).currentUser?.uid;
    final bookProvider = Provider.of<BookProvider>(context, listen: false);

    if (userId == null) return;
  // Controladores de texto para os campos do formulário
    final titleController = TextEditingController();
    final authorController = TextEditingController();
    final pagesController = TextEditingController();
    final descController = TextEditingController();
    final imageController = TextEditingController();
    String selectedShelf = 'Quero Ler';
    // Função para mostrar o modal de adicionar livro manualmente
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Adicionar Livro Manualmente',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A148C),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Título do Livro *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: authorController,
                  decoration: InputDecoration(
                    labelText: 'Nome do Autor *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pagesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Número Total de Páginas *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Descrição (Opcional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: imageController,
                  decoration: InputDecoration(
                    labelText: 'URL da Imagem da Capa (Opcional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedShelf, // Corrigido para 'value'
                  decoration: InputDecoration(
                    labelText: 'Estante Destino',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Quero Ler', child: Text('Quero Ler')),
                    DropdownMenuItem(value: 'Lendo', child: Text('Lendo')),
                    DropdownMenuItem(value: 'Lidos', child: Text('Lidos')),
                  ],
                  onChanged: (val) {
                    if (val != null) selectedShelf = val;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final title = titleController.text.trim();
                    final author = authorController.text.trim();
                    final pages = int.tryParse(pagesController.text) ?? 200;

                    if (title.isEmpty || author.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Preencha pelo menos o Título e o Autor!')),
                      );
                      return;
                    }

                    final customBook = BookModel(
                      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                      title: title,
                      authors: [author],
                      description: descController.text.trim().isEmpty
                          ? 'Livro cadastrado manualmente.'
                          : descController.text.trim(),
                      pageCount: pages,
                      thumbnailUrl: imageController.text.trim().isEmpty
                          ? null
                          : imageController.text.trim(),
                      status: selectedShelf,
                    );

                    bookProvider.addBookToShelf(userId, customBook, selectedShelf);
                    Navigator.pop(ctx);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Livro adicionado com sucesso!')),
                    );
                  },
                  child: const Text('Salvar Livro', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF6A1B9A),
          title: const Text("Emy's Versos", style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle, size: 30, color: Colors.white),
              tooltip: 'Adicionar Livro Manualmente',
              onPressed: () => _showAddCustomBookModal(context),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => Provider.of<AuthService>(context, listen: false).signOut(),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Color(0xFFE1BEE7),
            labelColor: Colors.white,
            unselectedLabelColor: Color(0xFFCE93D8),
            tabs: [
              Tab(text: 'Quero Ler'),
              Tab(text: 'Lendo'),
              Tab(text: 'Lidos'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ShelfList(status: 'Quero Ler'),
            ShelfList(status: 'Lendo'),
            ShelfList(status: 'Lidos'),
          ],
        ),
      ),
    );
  }
}
// Widget que representa a lista de livros em uma estante específica
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
  // Função para mostrar o diálogo de atualizar páginas lidas e total de páginas
  void _showUpdatePagesDialog(
      BuildContext context, String userId, BookModel book) {
    final totalPagesController = TextEditingController(text: book.pageCount.toString());
    final readPagesController = TextEditingController(text: book.pagesRead.toString());
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    final dbService = DatabaseService();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Editar Páginas\n"${book.title}"',
            style: const TextStyle(fontSize: 16, color: Color(0xFF4A148C))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: totalPagesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Total de Páginas do Livro',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: readPagesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Páginas Já Lidas',
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
            onPressed: () async {
              final newTotal = int.tryParse(totalPagesController.text) ?? book.pageCount;
              final newRead = int.tryParse(readPagesController.text) ?? book.pagesRead;

              if (newTotal != book.pageCount) {
                await dbService.updateBookDetails(userId, book.id, newTotal);
              }

              await bookProvider.updatePagesRead(userId, book.id, newRead, newTotal);

              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String userId, BookModel book) {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover Livro', style: TextStyle(color: Color(0xFF4A148C))),
        content: Text('Tem certeza que deseja remover "${book.title}" da sua estante?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await bookProvider.removeBookFromShelf(userId, book.id);
              } catch (error) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Erro ao remover livro: $error')),
                  );
                }
                return;
              }
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('"${book.title}" foi removido.')),
              );
            },
            child: const Text('Remover', style: TextStyle(color: Colors.white)),
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
                              width: 45, fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.book, size: 40, color: Color(0xFF8E24AA)))
                          : const Icon(Icons.book,
                              size: 40, color: Color(0xFF8E24AA)),
                      title: Text(book.title,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        // CORRIGIDO AQUI: Adicionado o asterisco (*) que faltava na multiplicação
                        '${book.authors.join(", ")}\nProgresso: ${book.pagesRead} de ${book.pageCount} págs. (${(progress * 100).toStringAsFixed(0)}%)',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'REMOVER') {
                            _confirmDelete(context, userId, book);
                          } else {
                            bookProvider.changeBookStatus(userId, book.id, value);
                          }
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
                          const PopupMenuDivider(),
                          const PopupMenuItem(
                            value: 'REMOVER',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Text('Remover da Estante', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
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
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () => _showUpdatePagesDialog(
                              context, userId, book),
                          icon: const Icon(Icons.edit, size: 16, color: Color(0xFF8E24AA)),
                          label: const Text('Páginas', style: TextStyle(color: Color(0xFF8E24AA))),
                        ),
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