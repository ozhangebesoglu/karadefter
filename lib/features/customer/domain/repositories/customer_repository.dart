import 'package:kara_defter/features/customer/domain/entities/customer_entity.dart';

abstract class CustomerRepository {
  Future<List<CustomerEntity>> getAllCustomers();
  Future<CustomerEntity?> getCustomerById(int id);
  Future<List<CustomerEntity>> searchCustomers(String query);
  Future<int> addCustomer(CustomerEntity customer);
  Future<int> updateCustomer(CustomerEntity customer);
  Future<int> deleteCustomer(int id);
  Future<int> getCustomerCount();
}
