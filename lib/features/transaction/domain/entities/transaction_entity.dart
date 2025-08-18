import 'package:equatable/equatable.dart';

enum TransactionType { credit, debit }

class TransactionEntity extends Equatable {
  final int? id;
  final String customerName;
  final TransactionType type;
  final double amount;
  final String? description;
  final DateTime date;
  final DateTime createdAt;

  const TransactionEntity({
    this.id,
    required this.customerName,
    required this.type,
    required this.amount,
    this.description,
    required this.date,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, customerName, type, amount, description, date, createdAt];

  TransactionEntity copyWith({
    int? id,
    String? customerName,
    TransactionType? type,
    double? amount,
    String? description,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
