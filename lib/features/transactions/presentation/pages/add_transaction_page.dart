import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../../data/models/transaction_model.dart';
import '../../../categories/data/models/category_model.dart';

class AddTransactionPage extends StatefulWidget {
  final int? transactionIndex;

  const AddTransactionPage({
    super.key,
    this.transactionIndex,
  });

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  CategoryModel? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingTransaction();
    });
  }

  void _loadExistingTransaction() {
    if (widget.transactionIndex != null) {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      final transaction = provider.transactions[widget.transactionIndex!];

      _amountController.text = transaction.amount.toString();
      _descriptionController.text = transaction.description;
      _selectedType = transaction.type;
      _selectedDate = transaction.date;
      _selectedCategory = provider.getCategoryById(transaction.categoryId);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transactionIndex == null
            ? 'Add Transaction'
            : 'Edit Transaction'),
        elevation: 0,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Transaction Type Toggle
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transaction Type',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          SegmentedButton<TransactionType>(
                            segments: const [
                              ButtonSegment(
                                value: TransactionType.expense,
                                label: Text('Expense'),
                                icon: Icon(Icons.remove_circle_outline),
                              ),
                              ButtonSegment(
                                value: TransactionType.income,
                                label: Text('Income'),
                                icon: Icon(Icons.add_circle_outline),
                              ),
                            ],
                            selected: {_selectedType},
                            onSelectionChanged:
                                (Set<TransactionType> selection) {
                              setState(() {
                                _selectedType = selection.first;
                                _selectedCategory = null; // Reset category
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Amount Input
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          prefixText: '₦ ',
                          hintText: '0.00',
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(
                            _selectedType == TransactionType.expense
                                ? Icons.remove_circle
                                : Icons.add_circle,
                            color: _selectedType == TransactionType.expense
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Category Selection
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<CategoryModel>(
                            value: _selectedCategory,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Select a category',
                            ),
                            items: (_selectedType == TransactionType.expense
                                    ? provider.getExpenseCategories()
                                    : provider.getIncomeCategories())
                                .map((category) => DropdownMenuItem(
                                      value: category,
                                      child: Row(
                                        children: [
                                          Text(
                                            category.icon,
                                            style:
                                                const TextStyle(fontSize: 18),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(category.name),
                                        ],
                                      ),
                                    ))
                                .toList(),
                            onChanged: (category) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a category';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Description Input
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Enter transaction details',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Date Selection
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: _selectDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today),
                                  const SizedBox(width: 12),
                                  Text(DateFormat('MMM dd, yyyy')
                                      .format(_selectedDate)),
                                  const Spacer(),
                                  const Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Save Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveTransaction,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            widget.transactionIndex == null
                                ? 'Add Transaction'
                                : 'Update Transaction',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final amount = double.parse(_amountController.text);

    bool success;
    if (widget.transactionIndex == null) {
      // Add new transaction
      success = await provider.addTransaction(
        amount: amount,
        description: _descriptionController.text.trim(),
        categoryId: _selectedCategory!.id,
        type: _selectedType,
        date: _selectedDate,
      );
    } else {
      // Update existing transaction
      success = await provider.updateTransaction(
        index: widget.transactionIndex!,
        amount: amount,
        description: _descriptionController.text.trim(),
        categoryId: _selectedCategory!.id,
        type: _selectedType,
        date: _selectedDate,
      );
    }

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.transactionIndex == null
                  ? 'Transaction added successfully!'
                  : 'Transaction updated successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to save transaction'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
