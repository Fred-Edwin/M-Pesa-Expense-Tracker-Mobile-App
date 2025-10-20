import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart' as models;
import '../services/transaction_provider.dart';
import '../widgets/transaction_list_item.dart';
import '../utils/app_theme.dart';
import 'transaction_detail_screen.dart';

class TransactionListScreen extends StatefulWidget {
  final String? initialCategory;

  const TransactionListScreen({
    Key? key,
    this.initialCategory,
  }) : super(key: key);

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<models.Transaction> _filteredTransactions = [];
  String? _selectedCategory;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransactions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    final provider = context.read<TransactionProvider>();

    if (_selectedCategory != null) {
      final transactions = await provider.filterByCategory(_selectedCategory!);
      setState(() {
        _filteredTransactions = transactions;
      });
    } else {
      setState(() {
        _filteredTransactions = provider.transactions;
      });
    }
  }

  Future<void> _handleSearch(String query) async {
    setState(() => _isSearching = true);

    final provider = context.read<TransactionProvider>();
    final results = await provider.searchTransactions(query);

    setState(() {
      _filteredTransactions = results;
      _isSearching = false;
    });
  }

  void _showFilterDialog() {
    final provider = context.read<TransactionProvider>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.radiusXLarge),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.spacing24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter by Category',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: AppSpacing.spacing16),
              ListTile(
                leading: const Icon(Icons.all_inclusive),
                title: const Text('All Categories'),
                trailing: _selectedCategory == null
                    ? const Icon(Icons.check, color: AppColors.primaryGreen)
                    : null,
                onTap: () {
                  setState(() => _selectedCategory = null);
                  _loadTransactions();
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ...provider.categories.map((category) {
                return ListTile(
                  leading: Text(category.icon, style: const TextStyle(fontSize: 24)),
                  title: Text(category.name),
                  trailing: _selectedCategory == category.name
                      ? const Icon(Icons.check, color: AppColors.primaryGreen)
                      : null,
                  onTap: () {
                    setState(() => _selectedCategory = category.name);
                    _loadTransactions();
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.05),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Transactions',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.textPrimary),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),

          // Category Filter Chip (if selected)
          if (_selectedCategory != null) _buildCategoryChip(),

          // Transaction List
          Expanded(
            child: _buildTransactionList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.spacing16),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
      ),
      child: TextField(
        controller: _searchController,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Search transactions...',
          hintStyle: Theme.of(context).textTheme.bodyMedium,
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _loadTransactions();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacing16,
            vertical: AppSpacing.spacing12,
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            _handleSearch(value);
          } else {
            _loadTransactions();
          }
        },
      ),
    );
  }

  Widget _buildCategoryChip() {
    final provider = context.watch<TransactionProvider>();
    final icon = provider.getCategoryIcon(_selectedCategory!);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16),
      child: Row(
        children: [
          Chip(
            avatar: Text(icon),
            label: Text(_selectedCategory!),
            deleteIcon: const Icon(Icons.close, size: 18),
            onDeleted: () {
              setState(() => _selectedCategory = null);
              _loadTransactions();
            },
            backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
            labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    }

    if (_filteredTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.spacing16),
            Text(
              'No transactions found',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16),
      itemCount: _filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = _filteredTransactions[index];

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.spacing8),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
            boxShadow: [AppShadows.cardShadow],
          ),
          child: TransactionListItem(
            transaction: transaction,
            showCategory: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionDetailScreen(
                    transaction: transaction,
                  ),
                ),
              ).then((_) {
                // Reload transactions when returning from detail screen
                _loadTransactions();
              });
            },
          ),
        );
      },
    );
  }
}
