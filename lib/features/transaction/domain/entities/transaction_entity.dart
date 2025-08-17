import 'package:equatable/equatable.dart';

enum TransactionType { credit, debit }

class TransactionEntity extends Equatable {
  final int? id;
  final int customerId;
  final TransactionType type;
  final double amount;
  final String? description;
  final DateTime date;
  final DateTime createdAt;

  const TransactionEntity({
    this.id,
    required this.customerId,
    required this.type,
    required this.amount,
    this.description,
    required this.date,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, customerId, type, amount, description, date, createdAt];

  TransactionEntity copyWith({
    int? id,
    int? customerId,
    TransactionType? type,
    double? amount,
    String? description,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
