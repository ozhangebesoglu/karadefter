import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:kara_defter/data/database/tables/customer_table.dart';
import 'package:kara_defter/data/database/tables/transaction_table.dart';

class AppDatabase {
  static const String _databaseName = 'kara_defter.db';
  static const int _databaseVersion = 1;

  static AppDatabase? _instance;
  static Database? _database;

  AppDatabase._();

  static AppDatabase get instance {
    _instance ??= AppDatabase._();
    return _instance!;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Customer tablosu oluştur
    await db.execute(CustomerTable.createTable);

    // Transaction tablosu oluştur
    await db.execute(TransactionTable.createTable);

    // Indexler oluştur
    await db.execute(CustomerTable.createIndexes);
    await db.execute(TransactionTable.createIndexes);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Gelecekte migration işlemleri burada yapılacak
    if (oldVersion < newVersion) {
      // Migration logic
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  Future<void> deleteDatabase() async {
    final String path = join(await getDatabasesPath(), _databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
