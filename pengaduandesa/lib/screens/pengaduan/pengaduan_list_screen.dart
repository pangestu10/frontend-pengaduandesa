// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pengaduan_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/pengaduan_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/pengaduan_card.dart';
import '../../widgets/loading_widget.dart';
import 'pengaduan_detail_screen.dart';

class PengaduanListScreen extends StatefulWidget {
  const PengaduanListScreen({super.key});

  @override
  State<PengaduanListScreen> createState() => _PengaduanListScreenState();
}

class _PengaduanListScreenState extends State<PengaduanListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  String? _selectedKategori;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    final provider = Provider.of<PengaduanProvider>(context, listen: false);
    await provider.fetchPengaduan(
      status: _selectedStatus,
      kategori: _selectedKategori,
      search: _searchController.text,
      refresh: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PengaduanProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdminOrKepalaDesa = authProvider.isAdminOrKepalaDesa;

    return Column(
      children: [
        // Header dengan gradient
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.secondaryColor, AppTheme.primaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              const Text(
                'Daftar Pengaduan',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Total: ${provider.pengaduanList.length} pengaduan',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.white70,
                ),
              ),
              const SizedBox(height: 20),
              
              // Search Box
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari pengaduan...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: const Icon(Icons.search, color: AppTheme.blue),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              _refreshData();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      _refreshData();
                    }
                  },
                  onSubmitted: (_) => _refreshData(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Filter Row
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.white70,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.filter_list, size: 18, color: AppTheme.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'Filter:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const Spacer(),
                        if (_selectedStatus != null || _selectedKategori != null)
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedStatus = null;
                                _selectedKategori = null;
                              });
                              _refreshData();
                            },
                            icon: const Icon(Icons.clear, size: 16, color: AppTheme.red),
                            label: const Text(
                              'Reset Filter',
                              style: TextStyle(color: AppTheme.red),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedStatus,
                            decoration: InputDecoration(
                              labelText: 'Status',
                              labelStyle: const TextStyle(color: Colors.blueGrey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppTheme.blue),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            style: const TextStyle(color: Colors.blueGrey),
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.blueGrey),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Semua Status', style: TextStyle(color: Colors.blueGrey)),
                              ),
                              ...PengaduanStatus.values.map((status) {
                                return DropdownMenuItem(
                                  value: status.name,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(status.name),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        status.name == 'diajukan'
                                            ? 'Diajukan'
                                            : status.name == 'diproses'
                                                ? 'Diproses'
                                                : status.name == 'ditolak'
                                                    ? 'Ditolak'
                                                    : 'Selesai',
                                        style: const TextStyle(color: Colors.blueGrey),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedStatus = value;
                              });
                              _refreshData();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedKategori,
                            decoration: InputDecoration(
                              labelText: 'Kategori',
                              labelStyle: const TextStyle(color: Colors.blueGrey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppTheme.blue),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            style: const TextStyle(color: Colors.blueGrey),
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.blueGrey),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Semua Kategori', style: TextStyle(color: Colors.blueGrey)),
                              ),
                              ...PengaduanKategori.values.map((kategori) {
                                return DropdownMenuItem(
                                  value: kategori.name,
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getCategoryIcon(kategori.name),
                                        size: 16,
                                        color: Colors.blueGrey,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        kategori.name == 'infrastruktur'
                                            ? 'Infrastruktur'
                                            : kategori.name == 'sosial'
                                                ? 'Sosial'
                                                : kategori.name == 'ekonomi'
                                                    ? 'Ekonomi'
                                                    : kategori.name == 'lingkungan'
                                                        ? 'Lingkungan'
                                                        : 'Lainnya',
                                        style: const TextStyle(color: Colors.blueGrey),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedKategori = value;
                              });
                              _refreshData();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Content Area
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            color: AppTheme.blue,
            backgroundColor: AppTheme.white,
            child: provider.isLoading && provider.pengaduanList.isEmpty
                ? const LoadingWidget(message: 'Memuat pengaduan...')
                : provider.pengaduanList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.inbox_outlined,
                              size: 80,
                              color: AppTheme.white30,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Belum ada pengaduan',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppTheme.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selectedStatus != null || _selectedKategori != null
                                  ? 'Coba ubah filter atau pencarian'
                                  : 'Mulai dengan membuat pengaduan baru',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.white80,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (!isAdminOrKepalaDesa) ...[
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/pengaduan/create');
                                },
                                icon: const Icon(Icons.add, color: AppTheme.white),
                                label: const Text(
                                  'Buat Pengaduan Baru',
                                  style: TextStyle(color: AppTheme.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.blue,
                                  foregroundColor: AppTheme.white,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: provider.pengaduanList.length,
                        itemBuilder: (context, index) {
                          final pengaduan = provider.pengaduanList[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: PengaduanCard(
                              pengaduan: pengaduan,
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
                        },
                      ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'diajukan':
        return Colors.orange;
      case 'diproses':
        return AppTheme.blue;
      case 'selesai':
        return AppTheme.green;
      case 'ditolak':
        return AppTheme.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String kategori) {
    switch (kategori) {
      case 'infrastruktur':
        return Icons.construction;
      case 'sosial':
        return Icons.people;
      case 'ekonomi':
        return Icons.attach_money;
      case 'lingkungan':
        return Icons.eco;
      default:
        return Icons.category;
    }
  }
}