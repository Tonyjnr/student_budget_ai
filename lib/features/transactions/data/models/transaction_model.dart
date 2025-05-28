import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String categoryId;

  @HiveField(4)
  final TransactionType type;

  @HiveField(5)
  final DateTime date;

  @HiveField(6)
  final double? aiConfidenceScore;

  @HiveField(7)
  final String? receiptImagePath;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;

  @HiveField(10)
  final Map<String, dynamic>? metadata;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.type,
    required this.date,
    this.aiConfidenceScore,
    this.receiptImagePath,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  factory TransactionModel.create({
    required String id,
    required double amount,
    required String description,
    required String categoryId,
    required TransactionType type,
    required DateTime date,
    double? aiConfidenceScore,
    String? receiptImagePath,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return TransactionModel(
      id: id,
      amount: amount,
      description: description,
      categoryId: categoryId,
      type: type,
      date: date,
      aiConfidenceScore: aiConfidenceScore,
      receiptImagePath: receiptImagePath,
      createdAt: now,
      updatedAt: now,
      metadata: metadata,
    );
  }

  TransactionModel copyWith({
    String? id,
    double? amount,
    String? description,
    String? categoryId,
    TransactionType? type,
    DateTime? date,
    double? aiConfidenceScore,
    String? receiptImagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      date: date ?? this.date,
      aiConfidenceScore: aiConfidenceScore ?? this.aiConfidenceScore,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, amount: $amount, description: $description, categoryId: $categoryId, type: $type, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

@HiveType(typeId: 1)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
}
