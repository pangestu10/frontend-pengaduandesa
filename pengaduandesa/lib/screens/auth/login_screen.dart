// ignore_for_file: use_build_context_synchronously, avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (success && authProvider.isAuthenticated) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (!mounted) return;
        
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          AppTheme.snackBar(
            content: authProvider.error ?? 'Login gagal',
            backgroundColor: AppTheme.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: [
                  // Header dengan efek transparan
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    decoration: BoxDecoration(
                      gradient: AppTheme.headerGradient,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: AppTheme.circleDecoration,
                          child: const Icon(
                            Icons.account_circle_rounded,
                            size: 60,
                            color: AppTheme.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Pengaduan Desa',
                          style: AppTheme.headlineStyle,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Silakan login untuk melanjutkan',
                          style: AppTheme.subtitleStyle,
                        ),
                      ],
                    ),
                  ),

                  // Form Container dengan efek glassmorphism
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppTheme.glassDecoration(),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Email Field
                            Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              child: TextFormField(
                                controller: _emailController,
                                style: const TextStyle(color: AppTheme.white),
                                decoration: AppTheme.textFieldDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icons.email_outlined,
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email tidak boleh kosong';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Email tidak valid';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            // Password Field
                            Container(
                              margin: const EdgeInsets.only(bottom: 30),
                              child: TextFormField(
                                controller: _passwordController,
                                style: const TextStyle(color: AppTheme.white),
                                obscureText: _obscurePassword,
                                decoration: AppTheme.textFieldDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icons.lock_outline,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppTheme.white80,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password tidak boleh kosong';
                                  }
                                  if (value.length < 6) {
                                    return 'Password minimal 6 karakter';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            // Login Button
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, _) {
                                return ElevatedButton(
                                  onPressed:
                                      authProvider.isLoading ? null : _login,
                                  style: AppTheme.primaryButtonStyle,
                                  child: authProvider.isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppTheme.blue,
                                          ),
                                        )
                                      : Text(
                                          'MASUK',
                                          style: AppTheme.buttonTextStyle,
                                        ),
                                );
                              },
                            ),

                            // Register Link
                            Container(
                              margin: const EdgeInsets.only(top: 24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Belum punya akun?',
                                    style: TextStyle(color: AppTheme.white80),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, '/register');
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                    ),
                                    child: Text(
                                      'Daftar di sini',
                                      style: AppTheme.linkTextStyle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Additional decorative elements
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          'Layanan Pengaduan Masyarakat',
                          style: AppTheme.bodyStyle,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppTheme.divider,
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: AppTheme.decorativeIcon(Icons.fingerprint),
                            ),
                            AppTheme.divider,
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}