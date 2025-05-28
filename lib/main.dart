import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'core/services/hive_service.dart';
import 'features/transactions/data/models/transaction_model.dart';
import 'features/budgets/data/models/budget_model.dart';
import 'features/categories/data/models/category_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(BudgetModelAdapter());
  Hive.registerAdapter(CategoryModelAdapter());

  // Initialize Hive Service
  await HiveService.init();

  runApp(const StudentBudgetApp());
}

class StudentBudgetApp extends StatelessWidget {
  const StudentBudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Add providers here as we create them
      ],
      child: const App(),
    );
  }
}
