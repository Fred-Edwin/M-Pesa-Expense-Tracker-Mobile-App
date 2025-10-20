import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/transaction_provider.dart';
import '../utils/app_theme.dart';
import 'dashboard_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = false;
  bool _isParsing = false;
  int _currentProgress = 0;
  int _totalMessages = 0;

  Future<void> _requestPermissionAndParse() async {
    final provider = context.read<TransactionProvider>();

    // Request SMS permission
    setState(() => _isLoading = true);

    final granted = await provider.requestSmsPermission();

    if (!granted) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showPermissionDeniedDialog();
      }
      return;
    }

    // Permission granted, parse messages
    setState(() {
      _isLoading = false;
      _isParsing = true;
    });

    final count = await provider.parseAndStoreSms(
      onProgress: (current, total) {
        setState(() {
          _currentProgress = current;
          _totalMessages = total;
        });
      },
    );

    if (mounted) {
      // Navigate to dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
        ),
      );
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Permission Required',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          content: const Text(
            'This app needs SMS permission to read M-Pesa messages and track your expenses. '
            'Please grant the permission in Settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Open app settings
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void _skipToApp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const DashboardScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spacing24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // App Icon/Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(AppRadius.radiusXLarge),
                  boxShadow: [AppShadows.elevatedShadow],
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  size: 64,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: AppSpacing.spacing32),

              // Title
              Text(
                'M-Pesa Expense Tracker',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.spacing16),

              // Description
              Text(
                'Automatically track your M-Pesa spending by reading your SMS messages',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.spacing48),

              // Loading/Parsing State
              if (_isLoading || _isParsing) ...[
                const CircularProgressIndicator(
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(height: AppSpacing.spacing16),
                Text(
                  _isParsing
                      ? 'Parsing M-Pesa messages...\n$_currentProgress / $_totalMessages'
                      : 'Requesting permission...',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                if (_isParsing && _totalMessages > 0) ...[
                  const SizedBox(height: AppSpacing.spacing16),
                  LinearProgressIndicator(
                    value: _currentProgress / _totalMessages,
                    backgroundColor: AppColors.dividerColor,
                    color: AppColors.primaryGreen,
                  ),
                ],
              ],

              if (!_isLoading && !_isParsing) ...[
                // Features List
                _buildFeatureItem(
                  Icons.sms,
                  'Auto-parse M-Pesa SMS',
                  'Automatically read and categorize your transactions',
                ),
                const SizedBox(height: AppSpacing.spacing16),
                _buildFeatureItem(
                  Icons.category,
                  'Smart Categorization',
                  'Transactions are automatically sorted into categories',
                ),
                const SizedBox(height: AppSpacing.spacing16),
                _buildFeatureItem(
                  Icons.privacy_tip,
                  'Privacy First',
                  'All data stays on your device. No cloud sync.',
                ),
              ],

              const Spacer(),

              // Get Started Button
              if (!_isLoading && !_isParsing)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _requestPermissionAndParse,
                    child: const Text('Get Started'),
                  ),
                ),

              const SizedBox(height: AppSpacing.spacing12),

              // Skip Button
              if (!_isLoading && !_isParsing)
                TextButton(
                  onPressed: _skipToApp,
                  child: Text(
                    'Skip for now',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.spacing12),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryGreen,
            size: 24,
          ),
        ),
        const SizedBox(width: AppSpacing.spacing16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.spacing4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
