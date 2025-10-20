import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_theme.dart';

class CategoryRow extends StatelessWidget {
  final String categoryName;
  final String icon;
  final double amount;
  final VoidCallback? onTap;
  final bool showDivider;

  const CategoryRow({
    Key? key,
    required this.categoryName,
    required this.icon,
    required this.amount,
    this.onTap,
    this.showDivider = true,
  }) : super(key: key);

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return 'KSh ${formatter.format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacing12),
            child: Row(
              children: [
                // Icon/Emoji
                Text(
                  icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: AppSpacing.spacing12),

                // Category Name
                Expanded(
                  child: Text(
                    categoryName,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),

                // Amount
                Text(
                  _formatCurrency(amount),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            color: AppColors.dividerColor,
          ),
      ],
    );
  }
}
