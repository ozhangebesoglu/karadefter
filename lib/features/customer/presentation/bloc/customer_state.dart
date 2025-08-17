import 'package:kara_defter/features/customer/domain/entities/customer_entity.dart';

abstract class CustomerState {}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<CustomerEntity> customers;
  CustomerLoaded(this.customers);
}

class CustomerSearchLoaded extends CustomerState {
  final List<CustomerEntity> customers;
  CustomerSearchLoaded(this.customers);
}

class CustomerDetailLoaded extends CustomerState {
  final CustomerEntity customer;
  CustomerDetailLoaded(this.customer);
}

class CustomerError extends CustomerState {
  final String message;
  CustomerError(this.message);
}

class CustomerSuccess extends CustomerState {
  final String message;
  CustomerSuccess(this.message);
}
