// ignore_for_file: deprecated_member_use, no_leading_underscores_for_local_identifiers, prefer_const_constructors, avoid_print, unused_local_variable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pengaduan_provider.dart';
import '../../theme/app_theme.dart';
import '../pengaduan/pengaduan_list_screen.dart';
import '../profile/profile_screen.dart';
import '../dashboard/dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final pengaduanProvider =
        Provider.of<PengaduanProvider>(context, listen: false);
    await pengaduanProvider.fetchPengaduan(refresh: true);
    await pengaduanProvider.fetchNotifications();
  }

  Widget _buildNotificationBadge(int count) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.red,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.white, width: 2),
      ),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      child: Text(
        count > 9 ? '9+' : count.toString(),
        style: const TextStyle(
          color: AppTheme.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final pengaduanProvider = Provider.of<PengaduanProvider>(context);

    final bool isAdminOrKepalaDesa = authProvider.isAdminOrKepalaDesa;

    final List<Widget> _pages = isAdminOrKepalaDesa
        ? const [
            DashboardScreen(),
            PengaduanListScreen(),
            ProfileScreen(),
          ]
        : const [
            PengaduanListScreen(),
            ProfileScreen(),
          ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.headerGradient,
                ),
                child: AppBar(
                  title: Text(
                    isAdminOrKepalaDesa ? 'Dashboard Admin' : 'Pengaduan Desa',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: AppTheme.white,
                    ),
                  ),
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  actions: [
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined,
                              color: AppTheme.white),
                          onPressed: () {},
                        ),
                        Positioned(
                          right: 6,
                          top: 6,
                          child: _buildNotificationBadge(
                              pengaduanProvider.unreadNotifications),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: AppTheme.white),
                      onPressed: () async {
                        final shouldLogout =
                            await _showLogoutDialog(context);
                        if (shouldLogout == true) {
                          await authProvider.logout();
                          if (!mounted) return;
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  decoration: AppTheme.glassDecoration(
                    borderRadius: 16,
                    shadowBlur: 15,
                    shadowSpread: 1,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _pages[_selectedIndex],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ================= FIXED BOTTOM NAV =================
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: const [
              AppTheme.primaryColor,
              AppTheme.secondaryColor,
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              _buildNavItem(
                index: 0,
                selectedIndex: _selectedIndex,
                isAdminOrKepalaDesa: isAdminOrKepalaDesa,
                isProfile: false,
              ),

              if (!isAdminOrKepalaDesa)
                SizedBox(
                  width: 44,
                  height: 44,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/pengaduan/create');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.white,
                      ),
                      child: const Icon(Icons.add,
                          size: 22, color: AppTheme.blue),
                    ),
                  ),
                )
              else
                _buildNavItem(
                  index: 1,
                  selectedIndex: _selectedIndex,
                  isAdminOrKepalaDesa: isAdminOrKepalaDesa,
                  isProfile: false,
                ),

              _buildNavItem(
                index: isAdminOrKepalaDesa ? 2 : 1,
                selectedIndex: _selectedIndex,
                isAdminOrKepalaDesa: isAdminOrKepalaDesa,
                isProfile: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= FIXED NAV ITEM =================
  Widget _buildNavItem({
    required int index,
    required int selectedIndex,
    required bool isAdminOrKepalaDesa,
    required bool isProfile,
  }) {
    final bool isSelected = selectedIndex == index;

    String label;
    IconData icon;
    IconData iconOutlined;

    if (isAdminOrKepalaDesa) {
      if (index == 0) {
        label = 'Dashboard';
        icon = Icons.dashboard;
        iconOutlined = Icons.dashboard_outlined;
      } else if (index == 1) {
        label = 'Pengaduan';
        icon = Icons.list_alt;
        iconOutlined = Icons.list_alt_outlined;
      } else {
        label = 'Profil';
        icon = Icons.person;
        iconOutlined = Icons.person_outline;
      }
    } else {
      if (index == 0) {
        label = 'Beranda';
        icon = Icons.home;
        iconOutlined = Icons.home_outlined;
      } else {
        label = 'Profil';
        icon = Icons.person;
        iconOutlined = Icons.person_outline;
      }
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: SizedBox(
          height: 48,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? icon : iconOutlined,
                size: isSelected ? 20 : 18,
                color: AppTheme.white,
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 8,
                  height: 1.0,
                  color: AppTheme.white,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
