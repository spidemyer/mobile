import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_model.dart';

class GoogleBooksService {
  static const String _googleBaseUrl = 'https://www.googleapis.com/books/v1/volumes';
  static const String _openLibraryBaseUrl = 'https://openlibrary.org/search.json';
  
  // Insira sua chave da Google Books se tiver (opcional)
  static const String _apiKey = 'AIzaSyAjnCPCKHwILctV0V3-9M6d7E2jycYD5yc'; 

  Future<List<BookModel>> searchBooks(String query) async {
    if (query.trim().isEmpty) return [];

    // Executa as duas buscas em paralelo para alta performance
    final results = await Future.wait([
      _searchGoogleBooks(query),
      _searchOpenLibrary(query),
    ]);

    final List<BookModel> combined = [];
    combined.addAll(results[0]);
    combined.addAll(results[1]);

    return combined;
  }

  // Busca na Google Books API
  Future<List<BookModel>> _searchGoogleBooks(String query) async {
    String urlString = '$_googleBaseUrl?q=${Uri.encodeComponent(query)}&maxResults=10';
    if (_apiKey.isNotEmpty) {
      urlString += '&key=$_apiKey';
    }

    try {
      final response = await http.get(Uri.parse(urlString));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic>? items = data['items'];
        if (items == null) return [];

        return items.map((json) => BookModel.fromApiJson(json)).toList();
      }
    } catch (e) {
      print('Erro ao buscar no Google Books: $e');
    }
    return [];
  }

  // Busca na Open Library API (Internet Archive)
  Future<List<BookModel>> _searchOpenLibrary(String query) async {
    final urlString = '$_openLibraryBaseUrl?q=${Uri.encodeComponent(query)}&limit=10';

    try {
      final response = await http.get(Uri.parse(urlString));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic>? docs = data['docs'];
        if (docs == null) return [];

        return docs.map((doc) {
          final String title = doc['title'] ?? 'Título desconhecido';
          final List<dynamic>? authorsList = doc['author_name'];
          final List<String> authors = authorsList != null
              ? authorsList.map((e) => e.toString()).toList()
              : ['Autor desconhecido'];
          final int pageCount = doc['number_of_pages_median'] ?? 0;
          final int? coverId = doc['cover_i'];

          String? thumbnailUrl;
          if (coverId != null) {
            thumbnailUrl = 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';
          }

          // Cria o link de leitura do Open Library
          final String key = doc['key'] ?? '';
          final String? previewLink = key.isNotEmpty ? 'https://openlibrary.org$key' : null;

          return BookModel(
            id: 'ol_${doc['key'] ?? title.hashCode}',
            title: title,
            authors: authors,
            description: 'Livro disponibilizado via Open Library.',
            pageCount: pageCount,
            thumbnailUrl: thumbnailUrl,
            previewLink: previewLink,
          );
        }).toList();
      }
    } catch (e) {
      print('Erro ao buscar na Open Library: $e');
    }
    return [];
  }
}