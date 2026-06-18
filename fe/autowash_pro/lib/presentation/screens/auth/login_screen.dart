import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:autowash_pro/core/theme/app_theme.dart';
import 'package:autowash_pro/presentation/providers/auth_provider.dart';
import 'package:autowash_pro/presentation/screens/auth/register_screen.dart';
import 'package:autowash_pro/presentation/screens/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Photography Background Image
          Positioned.fill(
            child: Opacity(
              opacity: 0.12,
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo & Title
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(36),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withAlpha(80),
                              blurRadius: 40,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.local_car_wash_rounded, size: 56, color: Colors.white),
                      ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),

                      const SizedBox(height: 32),

                      Text(
                        'AutoWash Pro',
                        style: GoogleFonts.outfit(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                          letterSpacing: -1,
                        ),
                      ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3),

                      const SizedBox(height: 12),

                      Text(
                        'Trải nghiệm rửa xe siêu tốc',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

                      const SizedBox(height: 50),

                      // Glassmorphism Form Container
                      ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(200),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(10),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                )
                              ]
                            ),
                            child: Column(
                              children: [
                                // Email Field
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: const TextStyle(color: AppTheme.textPrimary),
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textMuted),
                                  ),
                                  validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập email' : null,
                                ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideX(begin: -0.1),

                                const SizedBox(height: 20),

                                // Password Field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: const TextStyle(color: AppTheme.textPrimary),
                                  decoration: InputDecoration(
                                    labelText: 'Mật khẩu',
                                    prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textMuted),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                        color: AppTheme.textMuted,
                                      ),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                  validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập mật khẩu' : null,
                                ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideX(begin: -0.1),

                                const SizedBox(height: 32),

                                // Error message
                                Consumer<AuthProvider>(
                                  builder: (context, auth, _) {
                                    if (auth.error != null) {
                                      return Container(
                                        padding: const EdgeInsets.all(16),
                                        margin: const EdgeInsets.only(bottom: 24),
                                        decoration: BoxDecoration(
                                          color: AppTheme.error.withAlpha(25),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: AppTheme.error.withAlpha(50)),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.error_outline, color: AppTheme.error, size: 24),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(auth.error!, style: GoogleFonts.outfit(color: AppTheme.error, fontSize: 14, fontWeight: FontWeight.w600)),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),

                                // Login Button
                                Consumer<AuthProvider>(
                                  builder: (context, auth, _) {
                                    return SizedBox(
                                      width: double.infinity,
                                      height: 60,
                                      child: ElevatedButton(
                                        onPressed: auth.isLoading ? null : _handleLogin,
                                        child: auth.isLoading
                                            ? const SizedBox(
                                                width: 28, height: 28,
                                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                              )
                                            : Text(
                                                'Đăng nhập',
                                                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1),
                                              ),
                                      ),
                                    );
                                  },
                                ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideY(begin: 0.2),
                                
                                const SizedBox(height: 28),

                                // Register Link
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  children: [
                                    Text('Chưa có tài khoản? ', style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 15)),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                                      },
                                      child: Text(
                                        'Đăng ký ngay',
                                        style: GoogleFonts.outfit(
                                          color: AppTheme.primaryBlue,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideY(begin: 0.1),

                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
