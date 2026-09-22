import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/checkin_model.dart';

// Gerenciamento do bando de dados
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();
  // Getter para acessar o banco de dados
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('senai_checkin.db');
    return _database!;
  }
  // Inicializa o banco de dados
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }
  // Cria a tabela de registros
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE registros (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        data_hora TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        observacao TEXT,
        caminho_da_foto TEXT NOT NULL
      )
    ''');
  }
  // Inserir novo registro no banco de dados
  Future<int> insertRegistro(CheckInModel registro) async {
    final db = await database;
    return await db.insert('registros', registro.toMap());
  }
  // Recuperar todos os registros do banco de dados
  Future<List<CheckInModel>> getRegistros() async {
    final db = await database;
    final result = await db.query('registros', orderBy: 'id DESC');
    return result.map((json) => CheckInModel.fromMap(json)).toList();
  }

  // Deletar registro
Future<int> deleteRegistro(int id) async {
  final db = await instance.database;
  return await db.delete(
    'registros', // Nome da sua tabela
    where: 'id = ?', // Certifique-se de que o nome da coluna bate com o do seu banco ('id' ou '_id')
    whereArgs: [id],
  );
}

// Atualizar registro
Future<int> updateRegistro(CheckInModel registro) async {
  final db = await instance.database;
  return await db.update(
    'registros',
    registro.toMap(),
    where: 'id = ?',
    whereArgs: [registro.id],
  );
}
}