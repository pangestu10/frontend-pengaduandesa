// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pengaduan_provider.dart';
import '../../theme/app_theme.dart';

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
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = Provider.of<PengaduanProvider>(context, listen: false);
    // Fetch semua pengaduan untuk admin/kepala desa
    await provider.fetchPengaduan(refresh: true);
    // Statistik akan otomatis dihitung dari data lokal setelah fetch
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PengaduanProvider>(context);
    final stats = provider.stats;

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.blue,
      backgroundColor: AppTheme.white,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.headerGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dashboard Statistik',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ringkasan semua pengaduan warga',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Stats Grid
            if (stats == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _statCard(
                    context,
                    'Total',
                    stats.total,
                    Colors.blue,
                    Icons.assignment_outlined,
                  ),
                  _statCard(
                    context,
                    'Diajukan',
                    stats.diajukan,
                    Colors.orange,
                    Icons.pending_outlined,
                  ),
                  _statCard(
                    context,
                    'Diproses',
                    stats.diproses,
                    Colors.blueGrey,
                    Icons.settings_outlined,
                  ),
                  _statCard(
                    context,
                    'Ditolak',
                    stats.ditolak,
                    Colors.red,
                    Icons.cancel_outlined,
                  ),
                  _statCard(
                    context,
                    'Selesai',
                    stats.selesai,
                    Colors.green,
                    Icons.check_circle_outline,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
    BuildContext context,
    String label,
    int value,
    Color color,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


