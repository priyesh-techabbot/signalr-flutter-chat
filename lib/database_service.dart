import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._();

  factory DatabaseService() => instance;

  DatabaseService._();

  final String _internalDbName = 'internal_db.db';
  final _internalDbVersion = 1;

  /// Internal Database table
  String users = 'users';
  String chats = 'chats';

  Database? _internalDatabase;

  Future<Database> get internalDatabase async {
    if (_internalDatabase != null && _internalDatabase!.isOpen) {
      return _internalDatabase!;
    }
    _internalDatabase = await _initInternalDB();
    return _internalDatabase!;
  }

  Future<Database> _initInternalDB() async {
    String path = join(await getDatabasesPath(), _internalDbName);

    return await openDatabase(
      path,
      version: _internalDbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (Database db, int version) async {
        await db.execute(
          '''CREATE TABLE IF NOT EXISTS $users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL
              )''',
        );

        await db.execute(
          '''CREATE TABLE IF NOT EXISTS $chats (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                sendBy TEXT NOT NULL,
                recBy TEXT NOT NULL,
                message TEXT NOT NULL,
                createdAt TEXT NOT NULL
                )''',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {},
    );
  }

  Future<List<Map<String, Object?>>> rawQuery(Database db, String sql,
      [List<Object?>? arguments]) async {
    print("-------- DB Request --------");
    print(sql);
    if (arguments != null && arguments.isNotEmpty) print(arguments);

    final result = await db.rawQuery(sql, arguments);
    print("-------- DB Result of $sql --------");
    print(result);
    print("-------------------------");

    return result;
  }

  Future<int> insert(
    Database db,
    String sql,
    Map<String, dynamic> values,
  ) async {
    print("-------- DB Request --------");
    print(sql);
    print(values);

    final result = await db.insert(sql, values);

    print("-------- DB Result of $sql --------");
    print(result);
    print("-------------------------");

    return result;
  }
}
