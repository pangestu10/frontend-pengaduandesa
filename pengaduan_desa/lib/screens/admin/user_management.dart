import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pengguna'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.users.isEmpty
              ? const Center(child: Text('Belum ada data pengguna'))
              : ListView.builder(
                  itemCount: provider.users.length,
                  itemBuilder: (context, index) {
                    final user = provider.users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(user.initial),
                      ),
                      title: Text(user.nama),
                      subtitle: Text('${user.email} • ${user.role}'),
                      trailing: Icon(
                        user.isActive ? Icons.check_circle : Icons.cancel,
                        color: user.isActive ? Colors.green : Colors.red,
                      ),
                    );
                  },
                ),
    );
  }
}


