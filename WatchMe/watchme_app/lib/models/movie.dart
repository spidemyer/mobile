// Classe que representa um filme retornado da API ou do Banco de Dados
class Movie {
  final int id;
  final String title;
  final String posterPath;

  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
  });

  // Converte a resposta em JSON do TMDB para o modelo Dart
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? 'Título desconhecido',
      posterPath: json['poster_path'] ?? '',
    );
  }

  // Converte o registro retornado do SQLite em objeto Movie
  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'],
      title: map['title'],
      posterPath: map['posterPath'],
    );
  }

  // Converte o objeto Movie em Map para salvar no SQLite
  Map<String, dynamic> toMap(String userId) {
    return {
      'id': id,
      'title': title,
      'posterPath': posterPath,
      'userId': userId,
    };
  }
}