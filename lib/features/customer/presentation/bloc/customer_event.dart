import 'package:kara_defter/features/customer/domain/entities/customer_entity.dart';

abstract class CustomerEvent {}

class LoadCustomers extends CustomerEvent {}

class SearchCustomers extends CustomerEvent {
  final String query;
  SearchCustomers(this.query);
}

class AddCustomer extends CustomerEvent {
  final CustomerEntity customer;
  AddCustomer(this.customer);
}

class UpdateCustomer extends CustomerEvent {
  final CustomerEntity customer;
  UpdateCustomer(this.customer);
}

class DeleteCustomer extends CustomerEvent {
  final int customerId;
  DeleteCustomer(this.customerId);
}

class GetCustomerById extends CustomerEvent {
  final int customerId;
  GetCustomerById(this.customerId);
}
