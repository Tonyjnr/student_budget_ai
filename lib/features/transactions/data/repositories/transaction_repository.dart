// lib/features/transactions/data/repositories/transaction_repository.dart
import 'package:hive/hive.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  static const String _boxName = 'transactions';
  Box<TransactionModel>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<TransactionModel>(_boxName);
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _box?.add(transaction);
  }

  Future<void> updateTransaction(int key, TransactionModel transaction) async {
    await _box?.putAt(key, transaction);
  }

  Future<void> deleteTransaction(int key) async {
    await _box?.deleteAt(key);
  }

  List<TransactionModel> getAllTransactions() {
    return _box?.values.toList() ?? [];
  }

  List<TransactionModel> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    final transactions = getAllTransactions();
    return transactions.where((transaction) {
      return transaction.date
              .isAfter(startDate.subtract(const Duration(days: 1))) &&
          transaction.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  List<TransactionModel> getTransactionsByCategory(String categoryId) {
    final transactions = getAllTransactions();
    return transactions.where((t) => t.categoryId == categoryId).toList();
  }

  double getTotalSpentThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final monthTransactions =
        getTransactionsByDateRange(startOfMonth, endOfMonth);

    return monthTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getTotalIncomeThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final monthTransactions =
        getTransactionsByDateRange(startOfMonth, endOfMonth);

    return monthTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Map<String, double> getCategorySpending() {
    final transactions = getAllTransactions();
    final Map<String, double> categorySpending = {};

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        categorySpending[transaction.categoryId] =
            (categorySpending[transaction.categoryId] ?? 0) +
                transaction.amount;
      }
    }

    return categorySpending;
  }

  List<TransactionModel> getRecentTransactions({int limit = 10}) {
    final transactions = getAllTransactions();
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions.take(limit).toList();
  }
}
