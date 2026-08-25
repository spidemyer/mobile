import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class TmdbService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  
  // COLOQUE SUA CHAVE DE API DO TMDB AQUI:
  static const String _apiKey = 'ed3b799b395587e59c236d8e8fae2675';

  // Retorna a URL completa da imagem
  static String getImageUrl(String? posterPath) {
  if (posterPath == null || posterPath.isEmpty || posterPath == 'null') {
    // Retorna uma imagem genérica de placeholder
    return 'https://via.placeholder.com/500x750/1e293b/ffffff?text=Sem+Poster';
  }
  return 'https://image.tmdb.org/t/p/w500$posterPath';
}

  // Busca filmes populares para popular a tela inicial
  static Future<List<Movie>> getPopularMovies() async {
    final url = Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey&language=pt-BR');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        return results.map((json) => Movie.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Erro ao carregar populares: $e');
      return [];
    }
  }

  // Busca filmes por nome (Query Param)
  static Future<List<Movie>> searchMovies(String query) async {
    if (query.trim().isEmpty) {
      return getPopularMovies();
    }
    final url = Uri.parse(
      '$_baseUrl/search/movie?api_key=$_apiKey&query=${Uri.encodeComponent(query)}&language=pt-BR',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        return results.map((json) => Movie.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Erro na busca: $e');
      return [];
    }
  }
}