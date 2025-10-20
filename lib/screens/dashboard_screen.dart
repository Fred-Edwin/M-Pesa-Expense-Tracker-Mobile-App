import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/transaction_provider.dart';
import '../widgets/summary_card.dart';
import '../widgets/category_row.dart';
import '../widgets/transaction_list_item.dart';
import '../utils/app_theme.dart';
import 'transaction_list_screen.dart';
import 'transaction_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    // Initialize data on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().initialize();
    });
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);

    try {
      final provider = context.read<TransactionProvider>();
      await provider.syncNewMessages();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Synced new transactions'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error syncing: $e'),
            backgroundColor: AppColors.expenseRed,
          ),
        );
      }
    } finally {
      setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryGreen,
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _handleRefresh,
              color: AppColors.primaryGreen,
              child: CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: _buildHeader(context),
                  ),

                  // Summary Cards
                  SliverToBoxAdapter(
                    child: _buildSummaryCards(provider),
                  ),

                  // Spending by Category
                  SliverToBoxAdapter(
                    child: _buildCategoryBreakdown(provider),
                  ),

                  // Recent Transactions
                  SliverToBoxAdapter(
                    child: _buildRecentTransactions(provider),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16),
      decoration: const BoxDecoration(
        color: AppColors.primaryGreen,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My Expenses',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () {
                  // TODO: Implement notifications
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  // TODO: Implement settings
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(TransactionProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      child: Row(
        children: [
          Expanded(
            child: SummaryCard(
              label: 'Total Spent',
              amount: provider.totalSpent,
            ),
          ),
          const SizedBox(width: AppSpacing.spacing12),
          Expanded(
            child: SummaryCard(
              label: 'This Month',
              amount: provider.totalSpentThisMonth,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(TransactionProvider provider) {
    final topCategories = provider.getTopCategories(limit: 5);

    if (topCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing16,
        vertical: AppSpacing.spacing8,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.radiusLarge),
        boxShadow: [AppShadows.cardShadow],
      ),
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending by Category',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: AppSpacing.spacing16),
          ...topCategories.asMap().entries.map((entry) {
            final index = entry.key;
            final categoryEntry = entry.value;
            final isLast = index == topCategories.length - 1;

            return CategoryRow(
              categoryName: categoryEntry.key,
              icon: provider.getCategoryIcon(categoryEntry.key),
              amount: categoryEntry.value,
              showDivider: !isLast,
              onTap: () {
                // Navigate to filtered transaction list
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionListScreen(
                      initialCategory: categoryEntry.key,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(TransactionProvider provider) {
    final recentTransactions = provider.recentTransactions;

    if (recentTransactions.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(AppSpacing.spacing16),
        padding: const EdgeInsets.all(AppSpacing.spacing32),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.radiusLarge),
          boxShadow: [AppShadows.cardShadow],
        ),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.receipt_long,
                size: 64,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: AppSpacing.spacing16),
              Text(
                'No transactions yet',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.spacing8),
              Text(
                'Pull down to sync M-Pesa messages',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(AppSpacing.spacing16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.radiusLarge),
        boxShadow: [AppShadows.cardShadow],
      ),
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TransactionListScreen(),
                    ),
                  );
                },
                child: Text(
                  'View All',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacing8),
          ...recentTransactions.map((transaction) {
            return TransactionListItem(
              transaction: transaction,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionDetailScreen(
                      transaction: transaction,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
