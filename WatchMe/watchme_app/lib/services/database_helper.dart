import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/movie.dart';
import '../models/review.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();
  // Retorna a instância do banco de dados, inicializando se necessário
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('watchme.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

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

  // --- MÉTODOS DE FAVORITOS ---

  Future<void> addFavorite(Movie movie, String userId) async {
    final db = await instance.database;
    await db.insert(
      'favorites',
      movie.toMap(userId),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFavorite(int movieId, String userId) async {
    final db = await instance.database;
    await db.delete(
      'favorites',
      where: 'id = ? AND userId = ?',
      whereArgs: [movieId, userId],
    );
  }

  Future<bool> isFavorite(int movieId, String userId) async {
    final db = await instance.database;
    final maps = await db.query(
      'favorites',
      where: 'id = ? AND userId = ?',
      whereArgs: [movieId, userId],
    );
    return maps.isNotEmpty;
  }

  Future<List<Movie>> getFavorites(String userId) async {
    final db = await instance.database;
    final result = await db.query(
      'favorites',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return result.map((map) => Movie.fromMap(map)).toList();
  }

  // --- MÉTODOS DE AVALIAÇÕES ---

  Future<void> addReview(Review review) async {
    final db = await instance.database;
    await db.insert('reviews', review.toMap());
  }

  Future<List<Review>> getReviews(String userId) async {
    final db = await instance.database;
    final result = await db.query(
      'reviews',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return result.map((map) => Review.fromMap(map)).toList();
  }
}