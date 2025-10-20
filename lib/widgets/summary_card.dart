import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_theme.dart';

class SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final bool isCompact;

  const SummaryCard({
    Key? key,
    required this.label,
    required this.amount,
    this.isCompact = false,
  }) : super(key: key);

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return 'KSh ${formatter.format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.radiusLarge),
        boxShadow: [AppShadows.cardShadow],
      ),
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.spacing8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KSh ',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Flexible(
                child: Text(
                  NumberFormat('#,##0', 'en_US').format(amount),
                  style: AmountTextStyles.large,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
