import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/book_model.dart';
import '../viewmodels/book_provider.dart';

class ShelvesView extends StatelessWidget {
  const ShelvesView({super.key});

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

  // DIÁLOGO PARA EDITAR TOTAL DE PÁGINAS E PÁGINAS LIDAS
  void _showUpdatePagesDialog(BuildContext context, String userId, BookModel book) {
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
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

  // DIÁLOGO PARA DEFINIR DATA DE TÉRMINO (Aparece nos Lidos)
  void _showFinishedDateDialog(BuildContext context, String userId, BookModel book) {
    final dbService = DatabaseService();
    String selectedYear = book.finishedDate?.split('-')[0] ?? DateTime.now().year.toString();
    String selectedMonth = book.finishedDate?.split('-')[1] ?? DateTime.now().month.toString().padLeft(2, '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Data de Término\n"${book.title}"',
            style: const TextStyle(fontSize: 16, color: Color(0xFF4A148C))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Selecione o mês e ano em que terminou de ler:',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedYear,
                    decoration: const InputDecoration(labelText: 'Ano'),
                    items: ['2026', '2025', '2024', '2023']
                        .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) selectedYear = val;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedMonth,
                    decoration: const InputDecoration(labelText: 'Mês'),
                    items: {
                      '01': 'Janeiro', '02': 'Fevereiro', '03': 'Março', '04': 'Abril',
                      '05': 'Maio', '06': 'Junho', '07': 'Julho', '08': 'Agosto',
                      '09': 'Setembro', '10': 'Outubro', '11': 'Novembro', '12': 'Dezembro'
                    }.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                    onChanged: (val) {
                      if (val != null) selectedMonth = val;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final dateStr = '$selectedYear-$selectedMonth-01';
              await dbService.updateBookFinishedDate(userId, book.id, dateStr);
              if (ctx.mounted) Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data de leitura salva com sucesso!')),
              );
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

    if (userId == null) return const Center(child: Text("Usuário não autenticado"));

    return StreamBuilder<List<BookModel>>(
      stream: dbService.getUserBooksByStatus(userId, status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF6A1B9A)));
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: book.thumbnailUrl != null
                          ? Image.network(book.thumbnailUrl!, width: 45, fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const Icon(Icons.book, color: Color(0xFF8E24AA)))
                          : const Icon(Icons.book, size: 40, color: Color(0xFF8E24AA)),
                      title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        '${book.authors.join(", ")}\nProgresso: ${book.pagesRead} de ${book.pageCount} págs. (${(progress * 100).toStringAsFixed(0)}%)'
                        '${book.finishedDate != null ? "\nConcluído em: ${book.finishedDate}" : ""}',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (val) {
                          if (val == 'REMOVER') {
                            bookProvider.removeBookFromShelf(userId, book.id);
                          } else {
                            bookProvider.changeBookStatus(userId, book.id, val);
                          }
                        },
                        itemBuilder: (context) => [
                          if (status != 'Quero Ler') const PopupMenuItem(value: 'Quero Ler', child: Text('Mover para Quero Ler')),
                          if (status != 'Lendo') const PopupMenuItem(value: 'Lendo', child: Text('Mover para Lendo')),
                          if (status != 'Lidos') const PopupMenuItem(value: 'Lidos', child: Text('Mover para Lidos')),
                          const PopupMenuDivider(),
                          const PopupMenuItem(value: 'REMOVER', child: Text('Remover', style: TextStyle(color: Colors.red))),
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
                    // BOTÕES DE AÇÃO INFERIORES
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Botão exclusivo de Data de Leitura (aparece nos Lidos)
                        if (status == 'Lidos') ...[
                          OutlinedButton.icon(
                            onPressed: () => _showFinishedDateDialog(context, userId, book),
                            icon: const Icon(Icons.calendar_today, size: 14, color: Color(0xFF8E24AA)),
                            label: const Text('Data', style: TextStyle(color: Color(0xFF8E24AA), fontSize: 12)),
                          ),
                          const SizedBox(width: 8),
                        ],
                        // Botão de Editar Páginas (Disponível em todas as estantes)
                        OutlinedButton.icon(
                          onPressed: () => _showUpdatePagesDialog(context, userId, book),
                          icon: const Icon(Icons.edit, size: 14, color: Color(0xFF8E24AA)),
                          label: const Text('Páginas', style: TextStyle(color: Color(0xFF8E24AA), fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        // Botão de LER (Prévia)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFAB47BC), foregroundColor: Colors.white),
                          onPressed: () => _openBookReader(context, book.previewLink),
                          icon: const Icon(Icons.chrome_reader_mode, size: 16),
                          label: const Text('LER'),
                        ),
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