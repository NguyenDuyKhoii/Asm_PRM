import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:autowash_pro/core/theme/app_theme.dart';
import 'package:autowash_pro/data/services/api_service.dart';
import 'package:autowash_pro/presentation/providers/auth_provider.dart';
import 'package:autowash_pro/presentation/providers/booking_provider.dart';
import 'package:autowash_pro/presentation/providers/loyalty_provider.dart';
import 'package:autowash_pro/presentation/screens/auth/login_screen.dart';
import 'package:autowash_pro/presentation/screens/home/home_screen.dart';
import 'package:autowash_pro/presentation/screens/admin/admin_dashboard_screen.dart';

void main() {
  runApp(const AutoWashProApp());
}

class AutoWashProApp extends StatelessWidget {
  const AutoWashProApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(apiService)),
        ChangeNotifierProvider(create: (_) => BookingProvider(apiService)),
        ChangeNotifierProvider(create: (_) => LoyaltyProvider(apiService)),
      ],
      child: MaterialApp(
        title: 'AutoWash Pro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5)));

    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () async {
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.checkAuth();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => authProvider.isLoggedIn 
                  ? (authProvider.isAdmin ? const AdminDashboardScreen() : const HomeScreen())
                  : const LoginScreen(),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withAlpha(25),
                          borderRadius: BorderRadius.circular(36),
                          boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withAlpha(30), blurRadius: 30, spreadRadius: 5)],
                        ),
                        child: const Icon(Icons.local_car_wash_rounded, size: 64, color: AppTheme.primaryBlue),
                      ),
                      const SizedBox(height: 24),
                      const Text('AutoWash Pro', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, letterSpacing: -1)),
                      const SizedBox(height: 8),
                      Text('Smart Car Wash Booking', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
