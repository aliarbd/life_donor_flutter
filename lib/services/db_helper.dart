import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user_model.dart';

class DBHelper {
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'blood_donor.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await _createDatabase(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE users ADD COLUMN age INTEGER DEFAULT 0',
          );
          await db.execute('ALTER TABLE users ADD COLUMN city TEXT DEFAULT ""');
          await db.execute(
            'ALTER TABLE users ADD COLUMN gender TEXT DEFAULT ""',
          );
          await db.execute(
            'ALTER TABLE users ADD COLUMN division TEXT DEFAULT ""',
          );
          await db.execute(
            'ALTER TABLE users ADD COLUMN district TEXT DEFAULT ""',
          );
          await db.execute(
            'ALTER TABLE users ADD COLUMN upazila TEXT DEFAULT ""',
          );
        }
      },
    );
  }

  Future<void> _createDatabase(Database db) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        phone TEXT NOT NULL,
        age INTEGER NOT NULL,
        city TEXT NOT NULL,
        gender TEXT NOT NULL,
        division TEXT NOT NULL,
        district TEXT NOT NULL,
        upazila TEXT NOT NULL,
        blood_group TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  Future<UserModel?> authenticate(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  Future<bool> emailExists(String email) async {
    return await getUserByEmail(email) != null;
  }
}
