import 'package:sqflite/sqflite.dart';
import 'package:kara_defter/data/database/app_database.dart';
import 'package:kara_defter/features/customer/data/models/customer_model.dart';
import 'package:kara_defter/features/customer/domain/entities/customer_entity.dart';
import 'package:kara_defter/features/customer/domain/repositories/customer_repository.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final AppDatabase _database;

  CustomerRepositoryImpl(this._database);

  @override
  Future<List<CustomerEntity>> getAllCustomers() async {
    try {
      final db = await _database.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'customers',
        orderBy: 'name ASC',
      );

      return maps.map((map) => CustomerModel.fromMap(map).toEntity()).toList();
    } catch (e) {
      throw Exception('Müşteriler yüklenirken hata oluştu: $e');
    }
  }

  @override
  Future<CustomerEntity?> getCustomerById(int id) async {
    try {
      final db = await _database.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'customers',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return CustomerModel.fromMap(maps.first).toEntity();
      }
      return null;
    } catch (e) {
      throw Exception('Müşteri bulunamadı: $e');
    }
  }

  @override
  Future<List<CustomerEntity>> searchCustomers(String query) async {
    try {
      final db = await _database.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'customers',
        where: 'name LIKE ? OR phone LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'name ASC',
      );

      return maps.map((map) => CustomerModel.fromMap(map).toEntity()).toList();
    } catch (e) {
      throw Exception('Müşteri arama yapılırken hata oluştu: $e');
    }
  }

  @override
  Future<int> addCustomer(CustomerEntity customer) async {
    try {
      final db = await _database.database;
      final model = CustomerModel.fromEntity(customer);
      final now = DateTime.now();
      final customerToInsert = model.copyWith(createdAt: now, updatedAt: now);

      return await db.insert(
        'customers',
        customerToInsert.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Müşteri eklenirken hata oluştu: $e');
    }
  }

  @override
  Future<int> updateCustomer(CustomerEntity customer) async {
    try {
      final db = await _database.database;
      final model = CustomerModel.fromEntity(customer);
      final now = DateTime.now();
      final customerToUpdate = model.copyWith(updatedAt: now);

      return await db.update(
        'customers',
        customerToUpdate.toMap(),
        where: 'id = ?',
        whereArgs: [customer.id],
      );
    } catch (e) {
      throw Exception('Müşteri güncellenirken hata oluştu: $e');
    }
  }

  @override
  Future<int> deleteCustomer(int id) async {
    try {
      final db = await _database.database;
      return await db.delete(
        'customers',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Müşteri silinirken hata oluştu: $e');
    }
  }

  @override
  Future<int> getCustomerCount() async {
    try {
      final db = await _database.database;
      final result =
          await db.rawQuery('SELECT COUNT(*) as count FROM customers');
      return result.first['count'] as int? ?? 0;
    } catch (e) {
      throw Exception('Müşteri sayısı hesaplanırken hata oluştu: $e');
    }
  }
}
