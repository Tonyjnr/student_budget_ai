import 'package:hive/hive.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 3)
class BudgetModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryId;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final int month;

  @HiveField(4)
  final int year;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  @HiveField(7)
  final double? spent;

  @HiveField(8)
  final bool isActive;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.month,
    required this.year,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.spent,
    this.isActive = true,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory BudgetModel.create({
    required String id,
    required String categoryId,
    required double amount,
    required int month,
    required int year,
    double? spent,
    bool isActive = true,
  }) {
    final now = DateTime.now();
    return BudgetModel(
      id: id,
      categoryId: categoryId,
      amount: amount,
      month: month,
      year: year,
      createdAt: now,
      updatedAt: now,
      spent: spent ?? 0.0,
      isActive: isActive,
    );
  }

  BudgetModel copyWith({
    String? id,
    String? categoryId,
    double? amount,
    int? month,
    int? year,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? spent,
    bool? isActive,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      spent: spent ?? this.spent,
      isActive: isActive ?? this.isActive,
    );
  }

  double get remainingAmount => amount - (spent ?? 0.0);
  double get spentPercentage => (spent ?? 0.0) / amount;
  bool get isOverBudget => (spent ?? 0.0) > amount;

  @override
  String toString() {
    return 'BudgetModel(id: $id, categoryId: $categoryId, amount: $amount, month: $month, year: $year, spent: $spent)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BudgetModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
