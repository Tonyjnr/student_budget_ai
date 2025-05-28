import 'package:hive_flutter/hive_flutter.dart';
import '../../features/transactions/data/models/transaction_model.dart';
import '../../features/budgets/data/models/budget_model.dart';
import '../../features/categories/data/models/category_model.dart';

class HiveService {
  static const String transactionsBoxName = 'transactions';
  static const String budgetsBoxName = 'budgets';
  static const String categoriesBoxName = 'categories';
  static const String settingsBoxName = 'settings';

  static late Box<TransactionModel> _transactionsBox;
  static late Box<BudgetModel> _budgetsBox;
  static late Box<CategoryModel> _categoriesBox;
  static late Box _settingsBox;

  static Future<void> init() async {
    // Open boxes
    _transactionsBox =
        await Hive.openBox<TransactionModel>(transactionsBoxName);
    _budgetsBox = await Hive.openBox<BudgetModel>(budgetsBoxName);
    _categoriesBox = await Hive.openBox<CategoryModel>(categoriesBoxName);
    _settingsBox = await Hive.openBox(settingsBoxName);

    // Initialize default categories if empty
    if (_categoriesBox.isEmpty) {
      await _initializeDefaultCategories();
    }
  }

  // Getters for boxes
  static Box<TransactionModel> get transactionsBox => _transactionsBox;
  static Box<BudgetModel> get budgetsBox => _budgetsBox;
  static Box<CategoryModel> get categoriesBox => _categoriesBox;
  static Box get settingsBoxInstance => _settingsBox;

  static Future<void> _initializeDefaultCategories() async {
    final defaultCategories = [
      CategoryModel(
        id: 'food',
        name: 'Food & Dining',
        icon: 'restaurant',
        color: 0xFFFF6B6B,
        isDefault: true,
      ),
      CategoryModel(
        id: 'transport',
        name: 'Transportation',
        icon: 'directions_bus',
        color: 0xFF4ECDC4,
        isDefault: true,
      ),
      CategoryModel(
        id: 'education',
        name: 'Education',
        icon: 'school',
        color: 0xFF45B7D1,
        isDefault: true,
      ),
      CategoryModel(
        id: 'entertainment',
        name: 'Entertainment',
        icon: 'movie',
        color: 0xFF96CEB4,
        isDefault: true,
      ),
      CategoryModel(
        id: 'shopping',
        name: 'Shopping',
        icon: 'shopping_bag',
        color: 0xFFFECE1A,
        isDefault: true,
      ),
      CategoryModel(
        id: 'health',
        name: 'Health & Fitness',
        icon: 'local_hospital',
        color: 0xFFFF9FF3,
        isDefault: true,
      ),
      CategoryModel(
        id: 'utilities',
        name: 'Bills & Utilities',
        icon: 'receipt_long',
        color: 0xFF54A0FF,
        isDefault: true,
      ),
      CategoryModel(
        id: 'miscellaneous',
        name: 'Miscellaneous',
        icon: 'category',
        color: 0xFF9b59b6,
        isDefault: true,
      ),
      CategoryModel(
        id: 'income',
        name: 'Income',
        icon: 'account_balance_wallet',
        color: 0xFF2ECC71,
        isDefault: true,
      ),
    ];

    for (final category in defaultCategories) {
      await _categoriesBox.put(category.id, category);
    }
  }

  static Future<void> clearAllData() async {
    await _transactionsBox.clear();
    await _budgetsBox.clear();
    await _categoriesBox.clear();
    await _settingsBox.clear();

    // Re-initialize default categories
    await _initializeDefaultCategories();
  }

  static Future<void> close() async {
    await _transactionsBox.close();
    await _budgetsBox.close();
    await _categoriesBox.close();
    await _settingsBox.close();
  }
}
