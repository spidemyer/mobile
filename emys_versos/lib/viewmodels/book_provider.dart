import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/google_books_service.dart';
import '../services/database_service.dart';
// ViewModel para gerenciar a lógica de busca e manipulação de livros
class BookProvider extends ChangeNotifier {
  final GoogleBooksService _apiService = GoogleBooksService();
  final DatabaseService _dbService = DatabaseService();
  // Lista de livros resultantes da busca
  List<BookModel> _searchResults = [];
  bool _isLoading = false;

  List<BookModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;

  BookProvider() {
    loadFeaturedBooks();
  }
  // Carrega livros em destaque (bestsellers) ao iniciar
  Future<void> loadFeaturedBooks() async {
    _isLoading = true;
    notifyListeners();

    _searchResults = await _apiService.searchBooks('bestseller');
    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchBooks(String query) async {
    if (query.trim().isEmpty) {
      return loadFeaturedBooks();
    }

    _isLoading = true;
    notifyListeners();

    _searchResults = await _apiService.searchBooks(query);
    _isLoading = false;
    notifyListeners();
  }
  // Adiciona um livro à estante do usuário
  Future<void> addBookToShelf(String userId, BookModel book, String status) async {
    // IMPORTANTE: Limpa o ID para remover caracteres inválidos do Firestore (como '/')
    final cleanId = book.id.replaceAll('/', '_').replaceAll(' ', '_');

    final updatedBook = BookModel(
      id: cleanId,
      title: book.title,
      authors: book.authors,
      description: book.description,
      pageCount: book.pageCount,
      pagesRead: status == 'Lidos' ? book.pageCount : 0,
      thumbnailUrl: book.thumbnailUrl,
      status: status,
      previewLink: book.previewLink,
    );

    await _dbService.saveBook(userId, updatedBook);
    notifyListeners();
  }
  // Atualiza o status de um livro na estante do usuário
  Future<void> changeBookStatus(String userId, String bookId, String newStatus) async {
    await _dbService.updateBookStatus(userId, bookId, newStatus);
    notifyListeners();
  }
  // Atualiza o número de páginas lidas de um livro na estante do usuário
  Future<void> updatePagesRead(String userId, String bookId, int pagesRead, int totalPages) async {
    await _dbService.updatePagesRead(userId, bookId, pagesRead, totalPages);
    notifyListeners();
  }
  // Atualiza o total de páginas de um livro na estante do usuário
  Future<void> removeBookFromShelf(String userId, String bookId) async {
    await _dbService.deleteBook(userId, bookId);
    notifyListeners();
  }
}