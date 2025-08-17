import 'package:sqflite/sqflite.dart';
import 'package:kara_defter/data/database/tables/customer_table.dart';
import 'package:kara_defter/features/customer/data/models/customer_model.dart';

class CustomerDao {
  final Database database;

  CustomerDao(this.database);

  Future<List<CustomerModel>> getAllCustomers() async {
    final List<Map<String, dynamic>> maps = await database.query(
      CustomerTable.tableName,
      orderBy: '${CustomerTable.name} ASC',
    );

    return List.generate(maps.length, (i) {
      return CustomerModel.fromMap(maps[i]);
    });
  }

  Future<CustomerModel?> getCustomerById(int id) async {
    final List<Map<String, dynamic>> maps = await database.query(
      CustomerTable.tableName,
      where: '${CustomerTable.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return CustomerModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<CustomerModel>> searchCustomers(String query) async {
    final List<Map<String, dynamic>> maps = await database.query(
      CustomerTable.tableName,
      where: '${CustomerTable.name} LIKE ? OR ${CustomerTable.phone} LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: '${CustomerTable.name} ASC',
    );

    return List.generate(maps.length, (i) {
      return CustomerModel.fromMap(maps[i]);
    });
  }

  Future<int> insertCustomer(CustomerModel customer) async {
    final now = DateTime.now();
    final customerToInsert = customer.copyWith(createdAt: now, updatedAt: now);

    return await database.insert(
      CustomerTable.tableName,
      customerToInsert.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateCustomer(CustomerModel customer) async {
    final now = DateTime.now();
    final customerToUpdate = customer.copyWith(updatedAt: now);

    return await database.update(
      CustomerTable.tableName,
      customerToUpdate.toMap(),
      where: '${CustomerTable.id} = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(int id) async {
    return await database.delete(
      CustomerTable.tableName,
      where: '${CustomerTable.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> getCustomerCount() async {
    final result = await database.rawQuery(
      'SELECT COUNT(*) FROM ${CustomerTable.tableName}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
