import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kara_defter/features/customer/domain/entities/customer_entity.dart';
import 'package:kara_defter/features/customer/domain/repositories/customer_repository.dart';

// Events
abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomers extends CustomerEvent {}

class AddCustomer extends CustomerEvent {
  final CustomerEntity customer;

  const AddCustomer(this.customer);

  @override
  List<Object?> get props => [customer];
}

class UpdateCustomer extends CustomerEvent {
  final CustomerEntity customer;

  const UpdateCustomer(this.customer);

  @override
  List<Object?> get props => [customer];
}

class DeleteCustomer extends CustomerEvent {
  final int customerId;

  const DeleteCustomer(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class SearchCustomers extends CustomerEvent {
  final String query;

  const SearchCustomers(this.query);

  @override
  List<Object?> get props => [query];
}

// States
abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<CustomerEntity> customers;

  const CustomerLoaded(this.customers);

  @override
  List<Object?> get props => [customers];
}

class CustomerError extends CustomerState {
  final String message;

  const CustomerError(this.message);

  @override
  List<Object?> get props => [message];
}

class CustomerAdded extends CustomerState {
  final CustomerEntity customer;

  const CustomerAdded(this.customer);

  @override
  List<Object?> get props => [customer];
}

class CustomerUpdated extends CustomerState {
  final CustomerEntity customer;

  const CustomerUpdated(this.customer);

  @override
  List<Object?> get props => [customer];
}

class CustomerDeleted extends CustomerState {
  final int customerId;

  const CustomerDeleted(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

// BLoC
class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRepository _customerRepository;

  CustomerBloc(this._customerRepository) : super(CustomerInitial()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<AddCustomer>(_onAddCustomer);
    on<UpdateCustomer>(_onUpdateCustomer);
    on<DeleteCustomer>(_onDeleteCustomer);
    on<SearchCustomers>(_onSearchCustomers);
  }

  Future<void> _onLoadCustomers(
      LoadCustomers event, Emitter<CustomerState> emit) async {
    emit(CustomerLoading());
    try {
      final customers = await _customerRepository.getAllCustomers();
      emit(CustomerLoaded(customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onAddCustomer(
      AddCustomer event, Emitter<CustomerState> emit) async {
    try {
      final customerId = await _customerRepository.addCustomer(event.customer);
      final addedCustomer = event.customer.copyWith(id: customerId);
      emit(CustomerAdded(addedCustomer));

      // Reload customers list
      final customers = await _customerRepository.getAllCustomers();
      emit(CustomerLoaded(customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onUpdateCustomer(
      UpdateCustomer event, Emitter<CustomerState> emit) async {
    try {
      await _customerRepository.updateCustomer(event.customer);
      emit(CustomerUpdated(event.customer));

      // Reload customers list
      final customers = await _customerRepository.getAllCustomers();
      emit(CustomerLoaded(customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onDeleteCustomer(
      DeleteCustomer event, Emitter<CustomerState> emit) async {
    try {
      await _customerRepository.deleteCustomer(event.customerId);
      emit(CustomerDeleted(event.customerId));

      // Reload customers list
      final customers = await _customerRepository.getAllCustomers();
      emit(CustomerLoaded(customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onSearchCustomers(
      SearchCustomers event, Emitter<CustomerState> emit) async {
    if (event.query.isEmpty) {
      add(LoadCustomers());
      return;
    }

    emit(CustomerLoading());
    try {
      final customers = await _customerRepository.searchCustomers(event.query);
      emit(CustomerLoaded(customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }
}
