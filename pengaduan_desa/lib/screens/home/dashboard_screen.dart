import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pengaduan_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PengaduanProvider>(context);
    final stats = provider.stats;

    if (stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _statCard('Total', stats.total, Colors.blue),
        _statCard('Diajukan', stats.diajukan, Colors.orange),
        _statCard('Diproses', stats.diproses, Colors.blueGrey),
        _statCard('Ditolak', stats.ditolak, Colors.red),
        _statCard('Selesai', stats.selesai, Colors.green),
      ],
    );
  }

  Widget _statCard(String label, int value, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}


