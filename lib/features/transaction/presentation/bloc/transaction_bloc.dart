import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kara_defter/features/transaction/domain/entities/transaction_entity.dart';
import 'package:kara_defter/features/transaction/domain/repositories/transaction_repository.dart';

// Events
abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {}

class LoadTransactionsByCustomer extends TransactionEvent {
  final int customerId;

  const LoadTransactionsByCustomer(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class AddTransaction extends TransactionEvent {
  final TransactionEntity transaction;

  const AddTransaction(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class UpdateTransaction extends TransactionEvent {
  final TransactionEntity transaction;

  const UpdateTransaction(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransaction extends TransactionEvent {
  final int transactionId;

  const DeleteTransaction(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class SearchTransactions extends TransactionEvent {
  final String query;

  const SearchTransactions(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadSummary extends TransactionEvent {}

// States
abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<TransactionEntity> transactions;

  const TransactionLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}

class TransactionAdded extends TransactionState {
  final TransactionEntity transaction;

  const TransactionAdded(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class TransactionUpdated extends TransactionState {
  final TransactionEntity transaction;

  const TransactionUpdated(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class TransactionDeleted extends TransactionState {
  final int transactionId;

  const TransactionDeleted(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class SummaryLoaded extends TransactionState {
  final double totalCredit;
  final double totalDebit;
  final double netBalance;

  const SummaryLoaded({
    required this.totalCredit,
    required this.totalDebit,
    required this.netBalance,
  });

  @override
  List<Object?> get props => [totalCredit, totalDebit, netBalance];
}

// BLoC
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _transactionRepository;

  TransactionBloc(this._transactionRepository) : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<LoadTransactionsByCustomer>(_onLoadTransactionsByCustomer);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<SearchTransactions>(_onSearchTransactions);
    on<LoadSummary>(_onLoadSummary);
  }

  Future<void> _onLoadTransactions(
      LoadTransactions event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      final transactions = await _transactionRepository.getAllTransactions();
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onLoadTransactionsByCustomer(
      LoadTransactionsByCustomer event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      final transactions = await _transactionRepository
          .getTransactionsByCustomer(event.customerId);
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onAddTransaction(
      AddTransaction event, Emitter<TransactionState> emit) async {
    try {
      final transactionId =
          await _transactionRepository.addTransaction(event.transaction);
      final addedTransaction = event.transaction.copyWith(id: transactionId);
      emit(TransactionAdded(addedTransaction));

      // Reload transactions list
      final transactions = await _transactionRepository.getAllTransactions();
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onUpdateTransaction(
      UpdateTransaction event, Emitter<TransactionState> emit) async {
    try {
      await _transactionRepository.updateTransaction(event.transaction);
      emit(TransactionUpdated(event.transaction));

      // Reload transactions list
      final transactions = await _transactionRepository.getAllTransactions();
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onDeleteTransaction(
      DeleteTransaction event, Emitter<TransactionState> emit) async {
    try {
      await _transactionRepository.deleteTransaction(event.transactionId);
      emit(TransactionDeleted(event.transactionId));

      // Reload transactions list
      final transactions = await _transactionRepository.getAllTransactions();
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onSearchTransactions(
      SearchTransactions event, Emitter<TransactionState> emit) async {
    if (event.query.isEmpty) {
      add(LoadTransactions());
      return;
    }

    emit(TransactionLoading());
    try {
      final transactions =
          await _transactionRepository.searchTransactions(event.query);
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onLoadSummary(
      LoadSummary event, Emitter<TransactionState> emit) async {
    try {
      final totalCredit = await _transactionRepository.getTotalCredit();
      final totalDebit = await _transactionRepository.getTotalDebit();
      final netBalance = await _transactionRepository.getNetBalance();

      emit(SummaryLoaded(
        totalCredit: totalCredit,
        totalDebit: totalDebit,
        netBalance: netBalance,
      ));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }
}
