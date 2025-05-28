// lib/features/categories/data/services/category_service.dart
import 'package:hive/hive.dart';
import '../models/category_model.dart';

class CategoryService {
  static const String _boxName = 'categories';
  Box<CategoryModel>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<CategoryModel>(_boxName);

    // Initialize with student-focused categories if empty
    if (_box!.isEmpty) {
      await _initializeDefaultCategories();
    }
  }

  Future<void> _initializeDefaultCategories() async {
    final defaultCategories = [
      // Student Expenses
      CategoryModel(
        id: 'tuition',
        name: 'Tuition & Fees',
        icon: '🎓',
        color: 0xFF6366F1,
        isDefault: true,
      ),
      CategoryModel(
        id: 'books',
        name: 'Books & Supplies',
        icon: '📚',
        color: 0xFF8B5CF6,
        isDefault: true,
      ),
      CategoryModel(
        id: 'food',
        name: 'Food & Dining',
        icon: '🍕',
        color: 0xFFEF4444,
        isDefault: true,
      ),
      CategoryModel(
        id: 'transport',
        name: 'Transportation',
        icon: '🚌',
        color: 0xFF10B981,
        isDefault: true,
      ),
      CategoryModel(
        id: 'housing',
        name: 'Housing & Rent',
        icon: '🏠',
        color: 0xFFF59E0B,
        isDefault: true,
      ),
      CategoryModel(
        id: 'entertainment',
        name: 'Entertainment',
        icon: '🎬',
        color: 0xFFEC4899,
        isDefault: true,
      ),
      CategoryModel(
        id: 'health',
        name: 'Health & Fitness',
        icon: '💊',
        color: 0xFF06B6D4,
        isDefault: true,
      ),
      CategoryModel(
        id: 'clothing',
        name: 'Clothing',
        icon: '👕',
        color: 0xFF8B5A2B,
        isDefault: true,
      ),
      CategoryModel(
        id: 'technology',
        name: 'Technology',
        icon: '💻',
        color: 0xFF6B7280,
        isDefault: true,
      ),
      CategoryModel(
        id: 'subscriptions',
        name: 'Subscriptions',
        icon: '📱',
        color: 0xFF7C3AED,
        isDefault: true,
      ),
      CategoryModel(
        id: 'laundry',
        name: 'Laundry',
        icon: '👔',
        color: 0xFF0891B2,
        isDefault: true,
      ),
      CategoryModel(
        id: 'social',
        name: 'Social & Events',
        icon: '🎉',
        color: 0xFFF97316,
        isDefault: true,
      ),

      // Income Categories
      CategoryModel(
        id: 'job',
        name: 'Part-time Job',
        icon: '💼',
        color: 0xFF059669,
        isDefault: true,
      ),
      CategoryModel(
        id: 'allowance',
        name: 'Family Support',
        icon: '💝',
        color: 0xFFDC2626,
        isDefault: true,
      ),
      CategoryModel(
        id: 'scholarship',
        name: 'Scholarship',
        icon: '🏆',
        color: 0xFFCA8A04,
        isDefault: true,
      ),
      CategoryModel(
        id: 'freelance',
        name: 'Freelance Work',
        icon: '💻',
        color: 0xFF7C2D12,
        isDefault: true,
      ),
      CategoryModel(
        id: 'other_income',
        name: 'Other Income',
        icon: '💰',
        color: 0xFF15803D,
        isDefault: true,
      ),
    ];

    for (final category in defaultCategories) {
      await _box?.add(category);
    }
  }

  List<CategoryModel> getAllCategories() {
    return _box?.values.toList() ?? [];
  }

  List<CategoryModel> getExpenseCategories() {
    final expenseIds = [
      'tuition',
      'books',
      'food',
      'transport',
      'housing',
      'entertainment',
      'health',
      'clothing',
      'technology',
      'subscriptions',
      'laundry',
      'social'
    ];

    return getAllCategories()
        .where((cat) => expenseIds.contains(cat.id))
        .toList();
  }

  List<CategoryModel> getIncomeCategories() {
    final incomeIds = [
      'job',
      'allowance',
      'scholarship',
      'freelance',
      'other_income'
    ];

    return getAllCategories()
        .where((cat) => incomeIds.contains(cat.id))
        .toList();
  }

  CategoryModel? getCategoryById(String id) {
    try {
      return getAllCategories().firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    await _box?.add(category);
  }

  Future<void> updateCategory(int key, CategoryModel category) async {
    await _box?.putAt(key, category);
  }

  Future<void> deleteCategory(int key) async {
    final category = _box?.getAt(key);
    if (category != null && !category.isDefault) {
      await _box?.deleteAt(key);
    }
  }
}
