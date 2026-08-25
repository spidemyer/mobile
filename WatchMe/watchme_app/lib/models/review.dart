// Modelo para armazenar as avaliações do usuário
class Review {
  final int? id;
  final int movieId;
  final String movieTitle;
  final String posterPath;
  final double rating;
  final String comment;
  final String userId;

  Review({
    this.id,
    required this.movieId,
    required this.movieTitle,
    required this.posterPath,
    required this.rating,
    required this.comment,
    required this.userId, required username,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'movieId': movieId,
      'movieTitle': movieTitle,
      'posterPath': posterPath,
      'rating': rating,
      'comment': comment,
      'userId': userId,
    };
  }
 // Converte o registro retornado do SQLite em objeto Review
  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'],
      movieId: map['movieId'],
      movieTitle: map['movieTitle'],
      posterPath: map['posterPath'],
      rating: (map['rating'] as num).toDouble(),
      comment: map['comment'],
      userId: map['userId'], username: null,
    );
  }

  get username => null;
}