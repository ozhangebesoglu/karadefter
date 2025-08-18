import 'package:kara_defter/features/transaction/domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    super.id,
    required super.customerName,
    required super.type,
    required super.amount,
    super.description,
    required super.date,
    required super.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int?,
      customerName: json['customer_name'] as String,
      type: _stringToTransactionType(json['type'] as String),
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      customerName: entity.customerName,
      type: entity.type,
      amount: entity.amount,
      description: entity.description,
      date: entity.date,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'type': _transactionTypeToString(type),
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_name': customerName,
      'type': _transactionTypeToString(type),
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      customerName: map['customer_name'] as String,
      type: _stringToTransactionType(map['type'] as String),
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String?,
      date: DateTime.parse(map['date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  static TransactionType _stringToTransactionType(String type) {
    switch (type.toLowerCase()) {
      case 'credit':
        return TransactionType.credit;
      case 'debit':
        return TransactionType.debit;
      default:
        throw ArgumentError('Geçersiz işlem tipi: $type');
    }
  }

  static String _transactionTypeToString(TransactionType type) {
    switch (type) {
      case TransactionType.credit:
        return 'credit';
      case TransactionType.debit:
        return 'debit';
    }
  }

  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      customerName: customerName,
      type: type,
      amount: amount,
      description: description,
      date: date,
      createdAt: createdAt,
    );
  }

  TransactionModel copyWith({
    int? id,
    String? customerName,
    TransactionType? type,
    double? amount,
    String? description,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return TransactionModel(
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
