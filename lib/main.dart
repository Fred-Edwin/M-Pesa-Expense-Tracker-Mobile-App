import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/transaction_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/dashboard_screen.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: MaterialApp(
        title: 'M-Pesa Expense Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final provider = context.read<TransactionProvider>();

    // Wait a bit for splash effect
    await Future.delayed(const Duration(seconds: 2));

    // Check if user has granted permission before
    final hasPermission = await provider.checkSmsPermission();

    if (mounted) {
      if (hasPermission) {
        // User has already granted permission, go to dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        // First time user, show welcome screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.radiusXLarge),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                size: 64,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: AppSpacing.spacing24),
            Text(
              'M-Pesa Expense Tracker',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.spacing48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
