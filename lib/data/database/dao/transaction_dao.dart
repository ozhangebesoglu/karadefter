import 'package:sqflite/sqflite.dart';
import 'package:kara_defter/data/database/tables/transaction_table.dart';
import 'package:kara_defter/features/transaction/data/models/transaction_model.dart';

class TransactionDao {
  final Database database;

  TransactionDao(this.database);

  Future<List<TransactionModel>> getAllTransactions() async {
    final List<Map<String, dynamic>> maps = await database.query(
      TransactionTable.tableName,
      orderBy: '${TransactionTable.date} DESC',
    );

    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  Future<TransactionModel?> getTransactionById(int id) async {
    final List<Map<String, dynamic>> maps = await database.query(
      TransactionTable.tableName,
      where: '${TransactionTable.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return TransactionModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<TransactionModel>> getTransactionsByCustomer(
      String customerName) async {
    final List<Map<String, dynamic>> maps = await database.query(
      TransactionTable.tableName,
      where: '${TransactionTable.customerName} = ?',
      whereArgs: [customerName],
      orderBy: '${TransactionTable.date} DESC',
    );

    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final List<Map<String, dynamic>> maps = await database.query(
      TransactionTable.tableName,
      where: '${TransactionTable.date} BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: '${TransactionTable.date} DESC',
    );

    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  Future<int> insertTransaction(TransactionModel transaction) async {
    final now = DateTime.now();
    final transactionToInsert = transaction.copyWith(
      date: transaction.date,
      createdAt: now,
    );

    return await database.insert(
      TransactionTable.tableName,
      transactionToInsert.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    return await database.update(
      TransactionTable.tableName,
      transaction.toMap(),
      where: '${TransactionTable.id} = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    return await database.delete(
      TransactionTable.tableName,
      where: '${TransactionTable.id} = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalCredit() async {
    final result = await database.rawQuery('''
      SELECT SUM(${TransactionTable.amount}) 
      FROM ${TransactionTable.tableName} 
      WHERE ${TransactionTable.type} = 'credit'
    ''');
    return (result.first.values.first as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalDebit() async {
    final result = await database.rawQuery('''
      SELECT SUM(${TransactionTable.amount}) 
      FROM ${TransactionTable.tableName} 
      WHERE ${TransactionTable.type} = 'debit'
    ''');
    return (result.first.values.first as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getCustomerBalance(String customerName) async {
    final creditResult = await database.rawQuery(
      '''
      SELECT SUM(${TransactionTable.amount}) 
      FROM ${TransactionTable.tableName} 
      WHERE ${TransactionTable.customerName} = ? AND ${TransactionTable.type} = 'credit'
    ''',
      [customerName],
    );

    final debitResult = await database.rawQuery(
      '''
      SELECT SUM(${TransactionTable.amount}) 
      FROM ${TransactionTable.tableName} 
      WHERE ${TransactionTable.customerName} = ? AND ${TransactionTable.type} = 'debit'
    ''',
      [customerName],
    );

    final totalCredit =
        (creditResult.first.values.first as num?)?.toDouble() ?? 0.0;
    final totalDebit =
        (debitResult.first.values.first as num?)?.toDouble() ?? 0.0;

    return totalCredit - totalDebit;
  }

  Future<int> getTransactionCount() async {
    final result = await database.rawQuery(
      'SELECT COUNT(*) FROM ${TransactionTable.tableName}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
