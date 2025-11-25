import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../features/vault/domain/sneaker_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'sneaker_vault.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE sneakers(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            brand TEXT,
            model TEXT,
            colorway TEXT,
            image_path TEXT,
            price REAL,
            year INTEGER,
            date_added TEXT
          )
          ''',
        );
      },
    );
  }

  // Ajouter
  Future<int> insertSneaker(Sneaker sneaker) async {
    final db = await database;
    return await db.insert(
      'sneakers',
      sneaker.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Lire
  Future<List<Sneaker>> getSneakers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('sneakers', orderBy: 'date_added DESC');
    return List.generate(maps.length, (i) {
      return Sneaker.fromMap(maps[i]);
    });
  }

  // --- SUPPRIMER (C'est cette partie qui manquait !) ---
  Future<void> deleteSneaker(int id) async {
    final db = await database;
    await db.delete(
      'sneakers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}