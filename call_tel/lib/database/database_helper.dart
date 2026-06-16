import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper { // cria a classe do banco de dados
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init(); 

  Future<Database> get database async { //método para acessar o banco de dados
    if (_database != null) return _database!;
    _database = await _initDB('call_tel.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async { //método para iniciar o banco de dados
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase( //abre o banco de dados, criando-o se não existir
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async { //habilita as chaves estrangeiras para garantir a integridade referencial
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async { //método para criar as tabelas do banco de dados
    await db.execute('''
      CREATE TABLE contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL,
        address TEXT NOT NULL
      )
    ''');

    await db.execute(''' 
      CREATE TABLE additional_fields (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contact_id INTEGER NOT NULL,
        field_type TEXT NOT NULL,
        field_value TEXT NOT NULL,
        FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> insertContact(Map<String, dynamic> row) async { //método para inserir um contato no banco de dados
    final db = await instance.database;
    return await db.insert('contacts', row);
  }

  Future<List<Map<String, dynamic>>> queryAllContactsOrdered() async { //método para consultar todos os contatos
    final db = await instance.database;
    return await db.query('contacts', orderBy: 'name COLLATE NOCASE ASC');
  }

  Future<List<Map<String, dynamic>>> queryRecentContacts() async { //para consultar os contatos mais recentes
    final db = await instance.database; 
    return await db.query('contacts', orderBy: 'id DESC', limit: 3);
  }

  Future<int> updateContact(Map<String, dynamic> row) async { //método para atualizar um contato no banco de dados
    final db = await instance.database;
    final id = row['id'];
    return await db.update('contacts', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteContact(int id) async { //método para deletar um contato do banco de dados
    final db = await instance.database;
    return await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertField(Map<String, dynamic> row) async { //método para inserir um campo adicional para um contato no banco de dados
    final db = await instance.database;
    return await db.insert('additional_fields', row);
  }

  Future<List<Map<String, dynamic>>> queryFieldsForContact(int contactId) async { //método para consultar os campos adicionais de um contato específico no banco de dados
    final db = await instance.database; 
    return await db.query(
      'additional_fields',
      where: 'contact_id = ?',
      whereArgs: [contactId],
    );
  }
}