// lib/features/transactions/presentation/pages/transactions_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../../../categories/domain/providers/category_provider.dart';
import '../../data/models/transaction_model.dart';
import '../../../categories/data/models/category_model.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Income', 'Expense'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => _filterOptions
                .map((option) => PopupMenuItem(
                      value: option,
                      child: Text(option),
                    ))
                .toList(),
            child: const Icon(Icons.filter_list),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer2<TransactionProvider, CategoryProvider>(
        builder: (context, transactionProvider, categoryProvider, child) {
          if (transactionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = _getFilteredTransactions(
            transactionProvider.transactions,
            _selectedFilter,
          );

          if (transactions.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              _buildSummaryCard(transactions),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    final category = categoryProvider.getCategoryById(
                      transaction.categoryId,
                    );
                    return _buildTransactionCard(
                      context,
                      transaction,
                      category,
                      transactionProvider,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-transaction'),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<TransactionModel> _getFilteredTransactions(
    List<TransactionModel> transactions,
    String filter,
  ) {
    switch (filter) {
      case 'Income':
        return transactions
            .where((t) => t.type == TransactionType.income)
            .toList();
      case 'Expense':
        return transactions
            .where((t) => t.type == TransactionType.expense)
            .toList();
      default:
        return transactions;
    }
  }

  Widget _buildSummaryCard(List<TransactionModel> transactions) {
    final income = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    final expenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final balance = income - expenses;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Current Balance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '₦${NumberFormat('#,##0.00').format(balance)}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBalanceItem(
                'Income',
                income,
                Colors.green.shade300,
                Icons.arrow_upward,
              ),
              Container(
                height: 30,
                width: 1,
                color: Colors.white30,
              ),
              _buildBalanceItem(
                'Expenses',
                expenses,
                Colors.red.shade300,
                Icons.arrow_downward,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '₦${NumberFormat('#,##0.00').format(amount)}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    TransactionModel transaction,
    CategoryModel? category,
    TransactionProvider provider,
  ) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/add-transaction?id=${transaction.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Category Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getCategoryColor(category?.color as String?)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(category?.icon),
                  color: _getCategoryColor(category?.color as String?),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Transaction Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          category?.name ?? 'Unknown',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        const Spacer(),
                        Text(
                          DateFormat('MMM dd, yyyy').format(transaction.date),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Amount and Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIncome ? '+' : '-'}₦${NumberFormat('#,##0.00').format(transaction.amount)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      switch (value) {
                        case 'edit':
                          context.push('/add-transaction?id=${transaction.id}');
                          break;
                        case 'delete':
                          _showDeleteDialog(context, transaction, provider);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: Icon(
                      Icons.more_vert,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your expenses by adding your first transaction',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/add-transaction'),
            icon: const Icon(Icons.add),
            label: const Text('Add Transaction'),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'school':
        return Icons.school;
      case 'directions_bus':
        return Icons.directions_bus;
      case 'home':
        return Icons.home;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'movie':
        return Icons.movie;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'work':
        return Icons.work;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'trending_up':
        return Icons.trending_up;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String? colorName) {
    switch (colorName) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'teal':
        return Colors.teal;
      case 'pink':
        return Colors.pink;
      case 'indigo':
        return Colors.indigo;
      case 'amber':
        return Colors.amber;
      case 'cyan':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    TransactionModel transaction,
    TransactionProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Transaction'),
          content: Text(
            'Are you sure you want to delete "${transaction.description}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await provider.deleteTransaction(transaction.id as int);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaction deleted successfully'),
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
