import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kara_defter/features/customer/domain/repositories/customer_repository.dart';
import 'package:kara_defter/features/transaction/domain/repositories/transaction_repository.dart';

// Events
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {}

class RefreshDashboard extends DashboardEvent {}

// States
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final int customerCount;
  final double totalCredit;
  final double totalDebit;
  final double netBalance;
  final int transactionCount;

  const DashboardLoaded({
    required this.customerCount,
    required this.totalCredit,
    required this.totalDebit,
    required this.netBalance,
    required this.transactionCount,
  });

  @override
  List<Object?> get props =>
      [customerCount, totalCredit, totalDebit, netBalance, transactionCount];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final CustomerRepository _customerRepository;
  final TransactionRepository _transactionRepository;

  DashboardBloc(this._customerRepository, this._transactionRepository)
      : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
  }

  Future<void> _onLoadDashboard(
      LoadDashboard event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      final customerCount = await _customerRepository.getCustomerCount();
      final totalCredit = await _transactionRepository.getTotalCredit();
      final totalDebit = await _transactionRepository.getTotalDebit();
      final netBalance = await _transactionRepository.getNetBalance();

      // Get transaction count (approximate)
      final allTransactions = await _transactionRepository.getAllTransactions();
      final transactionCount = allTransactions.length;

      emit(DashboardLoaded(
        customerCount: customerCount,
        totalCredit: totalCredit,
        totalDebit: totalDebit,
        netBalance: netBalance,
        transactionCount: transactionCount,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onRefreshDashboard(
      RefreshDashboard event, Emitter<DashboardState> emit) async {
    add(LoadDashboard());
  }
}
