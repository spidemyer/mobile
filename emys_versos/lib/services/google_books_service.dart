import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../models/book_model.dart';
// Serviço para buscar livros usando Google Books API e Open Library API
class GoogleBooksService {
  static const String _googleBaseUrl =
      'https://www.googleapis.com/books/v1/volumes';
  static const String _openLibraryBaseUrl =
      'https://openlibrary.org/search.json';
  // Busca livros por título, autor ou ISBN
  Future<List<BookModel>> searchBooks(String query) async {
    if (query.trim().isEmpty) return [];

    final results = await Future.wait([
      _searchGoogleBooks(query),
      _searchOpenLibrary(query),
    ]);

    return [...results[0], ...results[1]];
  }
  // Busca livros na Google Books API
  Future<List<BookModel>> _searchGoogleBooks(String query) async {
    final uri = Uri.parse(_googleBaseUrl).replace(queryParameters: {
      'q': query,
      'maxResults': '10',
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        developer.log(
          'Google Books retornou status ${response.statusCode}.',
        );
        return [];
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>?;
      return items
              ?.map((item) => BookModel.fromApiJson(
                  item as Map<String, dynamic>))
              .toList() ??
          [];
    } on FormatException catch (error, stackTrace) {
      developer.log(
        'Resposta inválida do Google Books.',
        error: error,
        stackTrace: stackTrace,
      );
      return [];
    } on http.ClientException catch (error, stackTrace) {
      developer.log(
        'Falha ao consultar Google Books.',
        error: error,
        stackTrace: stackTrace,
      );
      return [];
    }
  }
  // Busca livros na Open Library API
  Future<List<BookModel>> _searchOpenLibrary(String query) async {
    final uri = Uri.parse(_openLibraryBaseUrl).replace(queryParameters: {
      'q': query,
      'limit': '10',
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        developer.log(
          'Open Library retornou status ${response.statusCode}.',
        );
        return [];
      }
  
      final data = json.decode(response.body) as Map<String, dynamic>;
      final docs = data['docs'] as List<dynamic>?;
      if (docs == null) return [];

      return docs.map((doc) {
        final book = doc as Map<String, dynamic>;
        final title = book['title'] as String? ?? 'Título desconhecido';
        final rawAuthors = book['author_name'] as List<dynamic>?;
        final authors = rawAuthors?.map((author) => author.toString()).toList() ??
            ['Autor desconhecido'];
        final coverId = book['cover_i'] as int?;
        final key = book['key'] as String? ?? '';

        return BookModel(
          id: 'ol_${key.isNotEmpty ? key : title.hashCode}',
          title: title,
          authors: authors,
          description: 'Livro disponibilizado via Open Library.',
          pageCount: (book['number_of_pages_median'] as num?)?.toInt() ?? 0,
          pagesRead: 0,
          status: 'Quero Ler',
          thumbnailUrl: coverId == null
              ? null
              : 'https://covers.openlibrary.org/b/id/$coverId-M.jpg',
          previewLink: key.isEmpty ? null : 'https://openlibrary.org$key',
        );
      }).toList();
    } on FormatException catch (error, stackTrace) {
      developer.log(
        'Resposta inválida da Open Library.',
        error: error,
        stackTrace: stackTrace,
      );
      return [];
    } on http.ClientException catch (error, stackTrace) {
      developer.log(
        'Falha ao consultar Open Library.',
        error: error,
        stackTrace: stackTrace,
      );
      return [];
    }
  }
}
