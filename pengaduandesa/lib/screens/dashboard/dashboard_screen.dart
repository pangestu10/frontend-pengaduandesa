// ignore_for_file: unnecessary_to_list_in_spreads, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:pengaduan_desa/models/pengaduan_model.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pengaduan_provider.dart';
import '../../theme/app_theme.dart';
import '../pengaduan/pengaduan_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PengaduanProvider>(context, listen: false);
      provider.fetchPengaduan(refresh: true);
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi';
    } else if (hour < 15) {
      return 'Selamat Siang';
    } else if (hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'diajukan':
        return AppTheme.yellow;
      case 'diproses':
        return AppTheme.orange;
      case 'selesai':
        return AppTheme.green;
      case 'ditolak':
        return AppTheme.red;
      default:
        return AppTheme.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'diajukan':
        return Icons.pending;
      case 'diproses':
        return Icons.autorenew;
      case 'selesai':
        return Icons.check_circle;
      case 'ditolak':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'diajukan':
        return 'Diajukan';
      case 'diproses':
        return 'Diproses';
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final pengaduanProvider = Provider.of<PengaduanProvider>(context);
    final pengaduanList = pengaduanProvider.pengaduanList;
    
    // Hitung statistik dari list pengaduan
    final totalPengaduan = pengaduanList.length;
    final pengaduanDiajukan = pengaduanList
        .where((p) => p.status == 'diajukan')
        .length;
    final pengaduanDiproses = pengaduanList
        .where((p) => p.status == 'diproses')
        .length;
    final pengaduanSelesai = pengaduanList
        .where((p) => p.status == 'selesai')
        .length;
    final pengaduanDitolak = pengaduanList
        .where((p) => p.status == 'ditolak')
        .length;
    
    // Hitung jumlah kategori unik
    final kategoriUnik = pengaduanList
        .map((p) => p.kategori)
        .toSet()
        .length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan greeting
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authProvider.user?.nama ?? 'Administrator',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.white70,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.glassGradient,
                      border: Border.all(color: AppTheme.white20, width: 2),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppTheme.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Ringkasan Statistik
              const Text(
                'Ringkasan Pengaduan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.white,
                ),
              ),
              const SizedBox(height: 12),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    title: 'Total Pengaduan',
                    value: totalPengaduan.toString(),
                    icon: Icons.list_alt,
                    color: AppTheme.blue,
                  ),
                  _buildStatCard(
                    title: 'Diajukan',
                    value: pengaduanDiajukan.toString(),
                    icon: Icons.pending,
                    color: AppTheme.yellow,
                  ),
                  _buildStatCard(
                    title: 'Diproses',
                    value: pengaduanDiproses.toString(),
                    icon: Icons.autorenew,
                    color: AppTheme.orange,
                  ),
                  _buildStatCard(
                    title: 'Selesai',
                    value: pengaduanSelesai.toString(),
                    icon: Icons.check_circle,
                    color: AppTheme.green,
                  ),
                  _buildStatCard(
                    title: 'Ditolak',
                    value: pengaduanDitolak.toString(),
                    icon: Icons.cancel,
                    color: AppTheme.red,
                  ),
                  _buildStatCard(
                    title: 'Kategori',
                    value: kategoriUnik.toString(),
                    icon: Icons.category,
                    color: AppTheme.purple,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Pengaduan Terbaru
              const Text(
                'Pengaduan Terbaru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.white,
                ),
              ),
              const SizedBox(height: 12),

              // List Pengaduan Terbaru
              if (pengaduanProvider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                )
              else if (pengaduanList.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.white10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 50,
                          color: AppTheme.white30,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Belum ada pengaduan',
                          style: TextStyle(
                            color: AppTheme.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...pengaduanList
                    .take(3)
                    .map((pengaduan) => _buildPengaduanItem(pengaduan))
                    .toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.8),
            color.withOpacity(0.4),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.white, size: 24),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.white,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPengaduanItem(Pengaduan pengaduan) {
    final statusColor = _getStatusColor(pengaduan.status);
    final statusIcon = _getStatusIcon(pengaduan.status);
    final statusText = _getStatusText(pengaduan.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.white10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.white20, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: statusColor.withOpacity(0.2),
          ),
          child: Icon(statusIcon, color: statusColor, size: 20),
        ),
        title: Text(
          pengaduan.judul,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppTheme.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kategori: ${pengaduan.kategoriText}',
              style: const TextStyle(
                color: AppTheme.white70,
                fontSize: 12,
              ),
            ),
            Text(
              'Tanggal: ${pengaduan.tanggalDiajukan.day}/${pengaduan.tanggalDiajukan.month}/${pengaduan.tanggalDiajukan.year}',
              style: const TextStyle(
                color: AppTheme.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
          ),
          child: Text(
            statusText.toUpperCase(),
            style: TextStyle(
              color: statusColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PengaduanDetailScreen(
                pengaduanId: pengaduan.id,
              ),
            ),
          );
        },
      ),
    );
  }
}