// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    if (user == null) {
      return Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: const Center(
          child: Text(
            'Tidak ada data pengguna',
            style: TextStyle(color: AppTheme.white),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header Profile
            Container(
              padding: const EdgeInsets.all(30),
              decoration: AppTheme.glassDecoration(),
              child: Column(
                children: [
                  // Avatar Profile
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppTheme.white, AppTheme.primaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.blue.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.white,
                      child: Text(
                        user.initial,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.blue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Nama dan Email
                  Text(
                    user.nama,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.white80,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  // Badge Role
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getRoleColor(user.role).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getRoleColor(user.role),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      user.role.toUpperCase(),
                      style: TextStyle(
                        color: _getRoleColor(user.role),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Informasi Detail
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.glassDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Detail',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildInfoRow(
                    icon: Icons.fingerprint,
                    label: 'NIK',
                    value: user.nik,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildInfoRow(
                    icon: Icons.phone,
                    label: 'No. Telepon',
                    value: user.telepon ?? '-',
                  ),
                  const SizedBox(height: 12),
                  
                  _buildInfoRow(
                    icon: Icons.location_on,
                    label: 'Alamat',
                    value: user.alamat ?? '-',
                  ),
                  const SizedBox(height: 12),
                  
                  _buildInfoRow(
                    icon: Icons.badge,
                    label: 'Peran',
                    value: _getRoleText(user.role),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Tombol Logout
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.glassDecoration(),
              child: Column(
                children: [
                  const Text(
                    'Ingin keluar dari akun Anda?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  ElevatedButton.icon(
                    onPressed: () async {
                      // Logout confirmation
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) => Dialog(
                          backgroundColor: AppTheme.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [AppTheme.red, AppTheme.red.withOpacity(0.7)],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.logout,
                                    size: 40,
                                    color: AppTheme.white,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Konfirmasi Logout',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Apakah Anda yakin ingin keluar?',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          side: const BorderSide(color: Colors.grey),
                                        ),
                                        child: const Text(
                                          'Batal',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.red,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          elevation: 3,
                                        ),
                                        child: const Text(
                                          'Keluar',
                                          style: TextStyle(
                                            color: AppTheme.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                      
                      if (shouldLogout == true) {
                        await auth.logout();
                        // ignore: use_build_context_synchronously
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.red,
                      foregroundColor: AppTheme.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    icon: const Icon(Icons.logout, color: AppTheme.white),
                    label: const Text('KELUAR DARI AKUN', style: TextStyle(color: AppTheme.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.white10,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.blue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppTheme.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return AppTheme.red;
      case 'kepala_desa':
        return Colors.purple;
      case 'warga':
        return AppTheme.green;
      default:
        return AppTheme.blue;
    }
  }

  String _getRoleText(String role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'kepala_desa':
        return 'Kepala Desa';
      case 'warga':
        return 'Warga Desa';
      default:
        return role;
    }
  }
}