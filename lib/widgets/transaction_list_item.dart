import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart' as models;
import '../utils/app_theme.dart';

class TransactionListItem extends StatelessWidget {
  final models.Transaction transaction;
  final VoidCallback? onTap;
  final bool showCategory;

  const TransactionListItem({
    Key? key,
    required this.transaction,
    this.onTap,
    this.showCategory = false,
  }) : super(key: key);

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return 'KSh ${formatter.format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.isExpense;
    final amountColor = isExpense ? AppColors.expenseRed : AppColors.successGreen;
    final amountPrefix = isExpense ? '-' : '+';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacing16,
          vertical: AppSpacing.spacing12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.recipient ?? 'Unknown',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.spacing4),
                      Row(
                        children: [
                          Text(
                            '${transaction.date} ${transaction.time ?? ''}',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          if (showCategory) ...[
                            const SizedBox(width: AppSpacing.spacing8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.spacing8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundColor,
                                borderRadius: BorderRadius.circular(AppRadius.radiusSmall),
                              ),
                              child: Text(
                                transaction.category,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.spacing12),
                Text(
                  '$amountPrefix${_formatCurrency(transaction.amount)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: amountColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
