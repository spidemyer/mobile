import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/movie.dart';
import '../models/review.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Retorna a instância do banco de dados, inicializando se precisar
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('watchme.db');
    return _database!;
  }

  // Inicia o banco de dados
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Cria as tabelas do banco de dados
  Future<void> _createDB(Database db, int version) async {
    // Tabela de Favoritos
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        posterPath TEXT NOT NULL,
        userId TEXT NOT NULL
      )
    ''');

    // Tabela de Avaliações
    await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        movieId INTEGER NOT NULL,
        movieTitle TEXT NOT NULL,
        posterPath TEXT NOT NULL,
        rating REAL NOT NULL,
        comment TEXT NOT NULL,
        userId TEXT NOT NULL
      )
    ''');
  }

// método para gerenciar os favoritos
  Future<void> addFavorite(Movie movie, String userId) async {
    final db = await instance.database;
    await db.insert(
      'favorites',
      movie.toMap(userId),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Remover filme dos favoritos
  Future<void> removeFavorite(int movieId, String userId) async {
    final db = await instance.database;
    await db.delete(
      'favorites',
      where: 'id = ? AND userId = ?',
      whereArgs: [movieId, userId],
    );
  }

  // Verifica se está nos favoritos
  Future<bool> isFavorite(int movieId, String userId) async {
    final db = await instance.database;
    final maps = await db.query(
      'favorites',
      where: 'id = ? AND userId = ?',
      whereArgs: [movieId, userId],
    );
    return maps.isNotEmpty;
  }

  // Retorna a lista de filmes favoritos do usuário
  Future<List<Movie>> getFavorites(String userId) async {
    final db = await instance.database;
    final result = await db.query(
      'favorites',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return result.map((map) => Movie.fromMap(map)).toList();
  }


//métodos para gerenciar as avaliações

  Future<void> addReview(Review review) async {
    final db = await instance.database;
    await db.insert('reviews', review.toMap());
  }

  // Retorna a lista de avaliações do usuário
  Future<List<Review>> getReviews(String userId) async {
    final db = await instance.database;
    final result = await db.query(
      'reviews',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return result.map((map) => Review.fromMap(map)).toList();
  }

  // Atualiza uma avaliação existente
  Future<int> updateReview(Review review) async {
    final db = await instance.database;
    return await db.update(
      'reviews',
      review.toMap(),
      where: 'id = ?',
      whereArgs: [review.id],
    );
  }

  // Exclui uma avaliação pelo ID
  Future<int> deleteReview(int id) async {
    final db = await instance.database;
    return await db.delete(
      'reviews',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}