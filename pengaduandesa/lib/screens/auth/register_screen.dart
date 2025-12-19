// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nikController = TextEditingController();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _teleponController = TextEditingController();
  final _alamatController = TextEditingController();

  bool _obscurePassword = true;
  String _selectedRole = 'warga'; // Default role

  @override
  void dispose() {
    _nikController.dispose();
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    ('📝 RegisterScreen._register - Role yang dipilih: $_selectedRole');
    ('📝 RegisterScreen._register - Email: ${_emailController.text.trim()}');

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      nik: _nikController.text.trim(),
      nama: _namaController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      role: _selectedRole,
      telepon: _teleponController.text.trim().isEmpty
          ? null
          : _teleponController.text.trim(),
      alamat:
          _alamatController.text.trim().isEmpty ? null : _alamatController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppTheme.snackBar(
          content: 'Registrasi berhasil, silakan login',
          backgroundColor: AppTheme.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        AppTheme.snackBar(
          content: authProvider.error ?? 'Registrasi gagal',
          backgroundColor: AppTheme.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
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
                                Icons.person_add_alt_1_rounded,
                                size: 60,
                                color: AppTheme.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Buat Akun Baru',
                              style: AppTheme.headlineStyle,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Lengkapi data berikut untuk registrasi',
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
                                // NIK Field
                                Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: TextFormField(
                                    controller: _nikController,
                                    style: const TextStyle(
                                        color: AppTheme.white),
                                    decoration:
                                        AppTheme.textFieldDecoration(
                                      labelText: 'NIK',
                                      prefixIcon: Icons.badge_outlined,
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'NIK tidak boleh kosong';
                                      }
                                      if (value.length < 8) {
                                        return 'NIK tidak valid';
                                      }
                                      return null;
                                    },
                                  ),
                                ),

                                // Nama Field
                                Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: TextFormField(
                                    controller: _namaController,
                                    style: const TextStyle(
                                        color: AppTheme.white),
                                    decoration:
                                        AppTheme.textFieldDecoration(
                                      labelText: 'Nama Lengkap',
                                      prefixIcon: Icons.person_outline,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Nama tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                  ),
                                ),

                                // Email Field
                                Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: TextFormField(
                                    controller: _emailController,
                                    style: const TextStyle(
                                        color: AppTheme.white),
                                    decoration:
                                        AppTheme.textFieldDecoration(
                                      labelText: 'Email',
                                      prefixIcon: Icons.email_outlined,
                                    ),
                                    keyboardType:
                                        TextInputType.emailAddress,
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
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: TextFormField(
                                    controller: _passwordController,
                                    style: const TextStyle(
                                        color: AppTheme.white),
                                    obscureText: _obscurePassword,
                                    decoration:
                                        AppTheme.textFieldDecoration(
                                      labelText: 'Password',
                                      prefixIcon: Icons.lock_outline,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons
                                                  .visibility_outlined
                                              : Icons
                                                  .visibility_off_outlined,
                                          color: AppTheme.white80,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
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

                                // Role Selection Dropdown
                                Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedRole,
                                    decoration: InputDecoration(
                                      labelText: 'Role',
                                      labelStyle: const TextStyle(
                                          color: AppTheme.white80),
                                      prefixIcon: const Icon(
                                        Icons.verified_user_outlined,
                                        color: AppTheme.white80,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: AppTheme.white30),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: AppTheme.white30),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: AppTheme.white,
                                            width: 1.5),
                                      ),
                                      filled: true,
                                      fillColor: AppTheme.white10,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 16,
                                      ),
                                    ),
                                    dropdownColor: const Color(0xFF1A1A2E),
                                    style: const TextStyle(
                                        color: AppTheme.white),
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: AppTheme.white80,
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'warga',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.person_outline,
                                              color: AppTheme.white,
                                              size: 20,
                                            ),
                                            SizedBox(width: 12),
                                            Text('Warga'),
                                          ],
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'kepala_desa',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.admin_panel_settings_outlined,
                                              color: AppTheme.white,
                                              size: 20,
                                            ),
                                            SizedBox(width: 12),
                                            Text('Kepala Desa'),
                                          ],
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'admin',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.settings_outlined,
                                              color: AppTheme.white,
                                              size: 20,
                                            ),
                                            SizedBox(width: 12),
                                            Text('Admin'),
                                          ],
                                        ),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        ('📝 RegisterScreen - Role dipilih: $value');
                                        setState(() {
                                          _selectedRole = value;
                                        });
                                        ('📝 RegisterScreen - _selectedRole setelah setState: $_selectedRole');
                                      }
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Role harus dipilih';
                                      }
                                      return null;
                                    },
                                  ),
                                ),

                                // Telepon Field (Optional)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: TextFormField(
                                    controller: _teleponController,
                                    style: const TextStyle(
                                        color: AppTheme.white),
                                    decoration:
                                        AppTheme.textFieldDecoration(
                                      labelText: 'No. Telepon (opsional)',
                                      prefixIcon: Icons.phone_outlined,
                                    ),
                                    keyboardType: TextInputType.phone,
                                  ),
                                ),

                                // Alamat Field (Optional)
                                Container(
                                  margin:
                                      const EdgeInsets.only(bottom: 30),
                                  child: TextFormField(
                                    controller: _alamatController,
                                    style: const TextStyle(
                                        color: AppTheme.white),
                                    decoration: InputDecoration(
                                      labelText: 'Alamat (opsional)',
                                      labelStyle: const TextStyle(
                                          color: AppTheme.white80),
                                      prefixIcon: const Icon(
                                        Icons.location_on_outlined,
                                        color: AppTheme.white80,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: AppTheme.white30),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: AppTheme.white30),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: AppTheme.white,
                                            width: 1.5),
                                      ),
                                      filled: true,
                                      fillColor: AppTheme.white10,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 16,
                                      ),
                                    ),
                                    maxLines: 3,
                                  ),
                                ),

                                // Register Button
                                Consumer<AuthProvider>(
                                  builder: (context, authProvider, _) {
                                    return ElevatedButton(
                                      onPressed: authProvider.isLoading
                                          ? null
                                          : _register,
                                      style: AppTheme.primaryButtonStyle,
                                      child: authProvider.isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppTheme.blue,
                                              ),
                                            )
                                          : Text(
                                              'DAFTAR',
                                              style:
                                                  AppTheme.buttonTextStyle,
                                            ),
                                    );
                                  },
                                ),

                                // Login Link
                                Container(
                                  margin: const EdgeInsets.only(top: 24),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Sudah punya akun?',
                                        style: TextStyle(
                                            color: AppTheme.white80),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets
                                              .symmetric(
                                            horizontal: 8,
                                          ),
                                        ),
                                        child: Text(
                                          'Login di sini',
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
                    ],
                  ),

                  // Footer dengan elemen dekoratif
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 40),
                    child: Column(
                      children: [
                        Text(
                          'Bergabung dengan warga desa lainnya',
                          style: AppTheme.bodyStyle,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppTheme.divider,
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12),
                              child: AppTheme.decorativeIcon(
                                  Icons.group_outlined),
                            ),
                            AppTheme.divider,
                          ],
                        ),
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