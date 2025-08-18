import 'package:kara_defter/features/transaction/domain/entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<List<TransactionEntity>> getAllTransactions();
  Future<List<TransactionEntity>> getTransactionsByCustomer(String customerName);
  Future<TransactionEntity?> getTransactionById(int id);
  Future<int> addTransaction(TransactionEntity transaction);
  Future<int> updateTransaction(TransactionEntity transaction);
  Future<int> deleteTransaction(int id);
  Future<double> getTotalCredit();
  Future<double> getTotalDebit();
  Future<double> getNetBalance();
  Future<List<TransactionEntity>> searchTransactions(String query);
}
