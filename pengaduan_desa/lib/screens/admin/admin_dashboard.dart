import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pengaduan_provider.dart';
import '../../providers/user_provider.dart';
import '../home/dashboard_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final pengaduanProvider = Provider.of<PengaduanProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await pengaduanProvider.fetchStats();
          await userProvider.fetchUsers();
        },
        child: ListView(
          children: [
            const SizedBox(
              height: 200,
              child: DashboardScreen(),
            ),
            const Divider(),
            ListTile(
              title: const Text('Total Pengaduan'),
              trailing: Text('${pengaduanProvider.stats?.total ?? 0}'),
            ),
            ListTile(
              title: const Text('Total Pengguna'),
              trailing: Text('${userProvider.users.length}'),
            ),
          ],
        ),
      ),
    );
  }
}



