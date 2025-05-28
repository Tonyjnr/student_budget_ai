// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';

class CategoryProvider with ChangeNotifier {
  final List<CategoryModel> _categories = [];

  List<CategoryModel> get categories => _categories;

  Future<void> loadCategories() async {
    // Simulate loading categories from a database or API
    await Future.delayed(const Duration(seconds: 1));
    _categories.addAll([
      CategoryModel(
          id: '1',
          name: 'Food',
          icon: 'restaurant',
          color: Colors.red.value,
          isDefault: true),
      CategoryModel(
          id: '2',
          name: 'Transport',
          icon: 'directions_bus',
          color: Colors.blue.value,
          isDefault: true),
      CategoryModel(
          id: '3',
          name: 'Shopping',
          icon: 'shopping_cart',
          color: Colors.green.value,
          isDefault: true),
    ]);
    notifyListeners();
  }

  CategoryModel? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((category) => category.id == categoryId);
    } catch (e) {
      return null;
    }
  }
}
