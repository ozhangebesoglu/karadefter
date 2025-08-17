import 'package:sqflite/sqflite.dart';
import 'package:kara_defter/data/database/app_database.dart';
import 'package:kara_defter/features/transaction/data/models/transaction_model.dart';
import 'package:kara_defter/features/transaction/domain/entities/transaction_entity.dart';
import 'package:kara_defter/features/transaction/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final AppDatabase _database;

  TransactionRepositoryImpl(this._database);

  @override
  Future<List<TransactionEntity>> getAllTransactions() async {
    try {
      final db = await _database.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        orderBy: 'date DESC',
      );

      return maps
          .map((map) => TransactionModel.fromMap(map).toEntity())
          .toList();
    } catch (e) {
      throw Exception('İşlemler yüklenirken hata oluştu: $e');
    }
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByCustomer(
      int customerId) async {
    try {
      final db = await _database.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        where: 'customer_id = ?',
        whereArgs: [customerId],
        orderBy: 'date DESC',
      );

      return maps
          .map((map) => TransactionModel.fromMap(map).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Müşteri işlemleri yüklenirken hata oluştu: $e');
    }
  }

  @override
  Future<TransactionEntity?> getTransactionById(int id) async {
    try {
      final db = await _database.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return TransactionModel.fromMap(maps.first).toEntity();
      }
      return null;
    } catch (e) {
      throw Exception('İşlem bulunamadı: $e');
    }
  }

  @override
  Future<int> addTransaction(TransactionEntity transaction) async {
    try {
      final db = await _database.database;
      final model = TransactionModel.fromEntity(transaction);

      return await db.insert(
        'transactions',
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('İşlem eklenirken hata oluştu: $e');
    }
  }

  @override
  Future<int> updateTransaction(TransactionEntity transaction) async {
    try {
      final db = await _database.database;
      final model = TransactionModel.fromEntity(transaction);

      return await db.update(
        'transactions',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
    } catch (e) {
      throw Exception('İşlem güncellenirken hata oluştu: $e');
    }
  }

  @override
  Future<int> deleteTransaction(int id) async {
    try {
      final db = await _database.database;
      return await db.delete(
        'transactions',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('İşlem silinirken hata oluştu: $e');
    }
  }

  @override
  Future<double> getTotalCredit() async {
    try {
      final db = await _database.database;
      final result = await db.rawQuery(
        'SELECT SUM(amount) as total FROM transactions WHERE type = "credit"',
      );
      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw Exception('Toplam alacak hesaplanırken hata oluştu: $e');
    }
  }

  @override
  Future<double> getTotalDebit() async {
    try {
      final db = await _database.database;
      final result = await db.rawQuery(
        'SELECT SUM(amount) as total FROM transactions WHERE type = "debit"',
      );
      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw Exception('Toplam borç hesaplanırken hata oluştu: $e');
    }
  }

  @override
  Future<double> getNetBalance() async {
    try {
      final credit = await getTotalCredit();
      final debit = await getTotalDebit();
      return credit - debit;
    } catch (e) {
      throw Exception('Net bakiye hesaplanırken hata oluştu: $e');
    }
  }

  @override
  Future<List<TransactionEntity>> searchTransactions(String query) async {
    try {
      final db = await _database.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT t.* FROM transactions t
        INNER JOIN customers c ON t.customer_id = c.id
        WHERE c.name LIKE ? OR t.description LIKE ?
        ORDER BY t.date DESC
      ''', ['%$query%', '%$query%']);

      return maps
          .map((map) => TransactionModel.fromMap(map).toEntity())
          .toList();
    } catch (e) {
      throw Exception('İşlem arama yapılırken hata oluştu: $e');
    }
  }
}
