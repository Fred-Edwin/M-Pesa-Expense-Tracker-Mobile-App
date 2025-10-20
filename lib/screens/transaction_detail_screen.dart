import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart' as models;
import '../services/transaction_provider.dart';
import '../utils/app_theme.dart';

class TransactionDetailScreen extends StatefulWidget {
  final models.Transaction transaction;

  const TransactionDetailScreen({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  late models.Transaction _transaction;

  @override
  void initState() {
    super.initState();
    _transaction = widget.transaction;
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return 'KSh ${formatter.format(amount)}';
  }

  void _showEditCategoryDialog() {
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
                'Change Category',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: AppSpacing.spacing16),
              ...provider.categories.map((category) {
                return ListTile(
                  leading: Text(category.icon, style: const TextStyle(fontSize: 24)),
                  title: Text(category.name),
                  trailing: _transaction.category == category.name
                      ? const Icon(Icons.check, color: AppColors.primaryGreen)
                      : null,
                  onTap: () async {
                    await provider.updateTransactionCategory(
                      _transaction.id!,
                      category.name,
                    );

                    if (mounted) {
                      setState(() {
                        _transaction = _transaction.copyWith(category: category.name);
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Category updated'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showAddNoteDialog() {
    final TextEditingController noteController = TextEditingController(
      text: _transaction.notes ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Add Note',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          content: TextField(
            controller: noteController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Enter your note here...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final provider = context.read<TransactionProvider>();
                await provider.updateTransactionNotes(
                  _transaction.id!,
                  noteController.text,
                );

                if (mounted) {
                  setState(() {
                    _transaction = _transaction.copyWith(notes: noteController.text);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Note saved'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = _transaction.isExpense;
    final amountColor = isExpense ? AppColors.expenseRed : AppColors.successGreen;
    final amountPrefix = isExpense ? '-' : '+';
    final provider = context.watch<TransactionProvider>();
    final categoryIcon = provider.getCategoryIcon(_transaction.category);

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
          'Transaction Details',
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.spacing16),

            // Amount Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppRadius.radiusLarge),
                boxShadow: [AppShadows.cardShadow],
              ),
              padding: const EdgeInsets.all(AppSpacing.spacing24),
              child: Column(
                children: [
                  // Amount
                  Text(
                    '$amountPrefix${_formatCurrency(_transaction.amount)}',
                    style: AmountTextStyles.large.copyWith(
                      fontSize: 32,
                      color: amountColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.spacing8),

                  // Merchant Name
                  Text(
                    _transaction.recipient ?? 'Unknown',
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.spacing24),

                  // Details Grid
                  _buildDetailRow('Category', '$categoryIcon ${_transaction.category}'),
                  const SizedBox(height: AppSpacing.spacing16),
                  _buildDetailRow('Transaction ID', _transaction.transactionId),
                  const SizedBox(height: AppSpacing.spacing16),
                  _buildDetailRow('Date', _transaction.date),
                  const SizedBox(height: AppSpacing.spacing16),
                  _buildDetailRow('Time', _transaction.time ?? 'N/A'),
                  const SizedBox(height: AppSpacing.spacing16),
                  _buildDetailRow(
                    'Balance After',
                    _transaction.balance != null
                        ? _formatCurrency(_transaction.balance!)
                        : 'N/A',
                  ),
                  const SizedBox(height: AppSpacing.spacing16),
                  _buildDetailRow('Type', _transaction.type),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.spacing16),

            // Notes Card (if exists)
            if (_transaction.notes != null && _transaction.notes!.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16),
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
                      'Note',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacing8),
                    Text(
                      _transaction.notes!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: AppSpacing.spacing16),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16),
              child: Column(
                children: [
                  // Edit Category Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _showEditCategoryDialog,
                      icon: const Icon(Icons.category),
                      label: const Text('Edit Category'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacing12),

                  // Add/Edit Note Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _showAddNoteDialog,
                      icon: const Icon(Icons.note_add),
                      label: Text(_transaction.notes == null ? 'Add Note' : 'Edit Note'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.spacing24),

            // Original SMS (Expandable)
            if (_transaction.smsBody != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppRadius.radiusLarge),
                  boxShadow: [AppShadows.cardShadow],
                ),
                child: ExpansionTile(
                  title: Text(
                    'Original SMS',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.spacing16),
                      child: Text(
                        _transaction.smsBody!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: AppSpacing.spacing32),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
