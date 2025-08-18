import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:kara_defter/data/database/tables/customer_table.dart';
import 'package:kara_defter/data/database/tables/transaction_table.dart';

class AppDatabase {
  static const String _databaseName = 'kara_defter.db';
  static const int _databaseVersion = 2;

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
    if (oldVersion < 2) {
      // Migration: customer_id'yi customer_name'e çevir
      try {
        // Geçici tablo oluştur
        await db.execute('''
          CREATE TABLE transactions_new (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customer_name TEXT NOT NULL,
            type TEXT NOT NULL CHECK (type IN ('credit', 'debit')),
            amount REAL NOT NULL CHECK (amount > 0),
            description TEXT,
            date DATETIME DEFAULT CURRENT_TIMESTAMP,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
          )
        ''');

        // Verileri kopyala (customer_id'yi customer_name'e çevirerek)
        await db.execute('''
          INSERT INTO transactions_new (id, customer_name, type, amount, description, date, created_at)
          SELECT t.id, c.name, t.type, t.amount, t.description, t.date, t.created_at
          FROM transactions t
          LEFT JOIN customers c ON t.customer_id = c.id
        ''');

        // Eski tabloyu sil
        await db.execute('DROP TABLE transactions');

        // Yeni tabloyu yeniden adlandır
        await db.execute('ALTER TABLE transactions_new RENAME TO transactions');

        // Indexleri oluştur
        await db.execute('CREATE INDEX idx_transactions_customer_name ON transactions(customer_name)');
        await db.execute('CREATE INDEX idx_transactions_date ON transactions(date)');
        await db.execute('CREATE INDEX idx_transactions_type ON transactions(type)');

      } catch (e) {
        // Migration başarısız olursa, tabloyu yeniden oluştur
        await db.execute('DROP TABLE IF EXISTS transactions');
        await db.execute(TransactionTable.createTable);
        await db.execute(TransactionTable.createIndexes);
      }
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
