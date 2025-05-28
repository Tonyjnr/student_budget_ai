// lib/features/transactions/presentation/providers/transaction_provider.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../../categories/data/services/category_service.dart';
import '../../../categories/data/models/category_model.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionRepository _repository = TransactionRepository();
  final CategoryService _categoryService = CategoryService();

  List<TransactionModel> _transactions = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<TransactionModel> get transactions => _transactions;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filter getters
  List<TransactionModel> get expenseTransactions =>
      _transactions.where((t) => t.type == TransactionType.expense).toList();

  List<TransactionModel> get incomeTransactions =>
      _transactions.where((t) => t.type == TransactionType.income).toList();

  double get totalSpentThisMonth => _repository.getTotalSpentThisMonth();
  double get totalIncomeThisMonth => _repository.getTotalIncomeThisMonth();
  double get netBalanceThisMonth => totalIncomeThisMonth - totalSpentThisMonth;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.init();
      await _categoryService.init();
      await loadTransactions();
      await loadCategories();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTransactions() async {
    try {
      _transactions = _repository.getAllTransactions();
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    try {
      _categories = _categoryService.getAllCategories();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addTransaction({
    required double amount,
    required String description,
    required String categoryId,
    required TransactionType type,
    DateTime? date,
    String? receiptImagePath,
    double aiConfidenceScore = 0.0,
  }) async {
    try {
      final transaction = TransactionModel(
        id: const Uuid().v4(),
        amount: amount,
        description: description,
        categoryId: categoryId,
        type: type,
        date: date ?? DateTime.now(),
        receiptImagePath: receiptImagePath,
        aiConfidenceScore: aiConfidenceScore,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.addTransaction(transaction);
      await loadTransactions();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTransaction({
    required int index,
    required double amount,
    required String description,
    required String categoryId,
    required TransactionType type,
    DateTime? date,
    String? receiptImagePath,
    double? aiConfidenceScore,
  }) async {
    try {
      final existingTransaction = _transactions[index];
      final updatedTransaction = TransactionModel(
        id: existingTransaction.id,
        amount: amount,
        description: description,
        categoryId: categoryId,
        type: type,
        date: date ?? existingTransaction.date,
        receiptImagePath:
            receiptImagePath ?? existingTransaction.receiptImagePath,
        aiConfidenceScore:
            aiConfidenceScore ?? existingTransaction.aiConfidenceScore,
        createdAt: existingTransaction.createdAt,
        updatedAt: DateTime.now(),
      );

      await _repository.updateTransaction(index, updatedTransaction);
      await loadTransactions();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTransaction(int index) async {
    try {
      await _repository.deleteTransaction(index);
      await loadTransactions();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  List<TransactionModel> getTransactionsByCategory(String categoryId) {
    return _transactions.where((t) => t.categoryId == categoryId).toList();
  }

  List<TransactionModel> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _transactions.where((transaction) {
      return transaction.date
              .isAfter(startDate.subtract(const Duration(days: 1))) &&
          transaction.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  Map<String, double> getCategorySpending() {
    final Map<String, double> categorySpending = {};

    for (final transaction in _transactions) {
      if (transaction.type == TransactionType.expense) {
        categorySpending[transaction.categoryId] =
            (categorySpending[transaction.categoryId] ?? 0) +
                transaction.amount;
      }
    }

    return categorySpending;
  }

  CategoryModel? getCategoryById(String id) {
    return _categoryService.getCategoryById(id);
  }

  List<CategoryModel> getExpenseCategories() {
    return _categoryService.getExpenseCategories();
  }

  List<CategoryModel> getIncomeCategories() {
    return _categoryService.getIncomeCategories();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
