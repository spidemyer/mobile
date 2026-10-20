import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/google_books_service.dart';
import '../services/database_service.dart';

class BookProvider extends ChangeNotifier {
  final GoogleBooksService _apiService = GoogleBooksService();
  final DatabaseService _dbService = DatabaseService();

  List<BookModel> _searchResults = [];
  bool _isLoading = false;

  List<BookModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;

  BookProvider() {
    // Carrega sugestões de best-sellers ao abrir a tela de busca
    loadFeaturedBooks();
  }

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

  Future<void> addBookToShelf(
      String userId, BookModel book, String status) async {
    final updatedBook = BookModel(
      id: book.id,
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
  }

  Future<void> changeBookStatus(
      String userId, String bookId, String newStatus) async {
    await _dbService.updateBookStatus(userId, bookId, newStatus);
  }

  // Atualiza o progresso de leitura
  Future<void> updatePagesRead(
      String userId, String bookId, int pagesRead, int totalPages) async {
    await _dbService.updatePagesRead(userId, bookId, pagesRead, totalPages);
  }
}