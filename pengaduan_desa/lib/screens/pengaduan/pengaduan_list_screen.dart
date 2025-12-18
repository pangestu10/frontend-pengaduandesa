import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pengaduan_provider.dart';
import '../../models/pengaduan_model.dart';
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari pengaduan...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _refreshData();
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  if (value.isEmpty) {
                    _refreshData();
                  }
                },
                onSubmitted: (_) => _refreshData(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Semua Status'),
                        ),
                        ...PengaduanStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status.name,
                            child: Text(
                              status.name == 'diajukan'
                                  ? 'Diajukan'
                                  : status.name == 'diproses'
                                      ? 'Diproses'
                                      : status.name == 'ditolak'
                                          ? 'Ditolak'
                                          : 'Selesai',
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedKategori,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Semua Kategori'),
                        ),
                        ...PengaduanKategori.values.map((kategori) {
                          return DropdownMenuItem(
                            value: kategori.name,
                            child: Text(
                              kategori.name == 'infrastruktur'
                                  ? 'Infrastruktur'
                                  : kategori.name == 'sosial'
                                      ? 'Sosial'
                                      : kategori.name == 'ekonomi'
                                          ? 'Ekonomi'
                                          : kategori.name == 'lingkungan'
                                              ? 'Lingkungan'
                                              : 'Lainnya',
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
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            child: provider.isLoading && provider.pengaduanList.isEmpty
                ? const LoadingWidget(message: 'Memuat pengaduan...')
                : provider.pengaduanList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Belum ada pengaduan',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: provider.pengaduanList.length,
                        itemBuilder: (context, index) {
                          final pengaduan = provider.pengaduanList[index];
                          return PengaduanCard(
                            pengaduan: pengaduan,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PengaduanDetailScreen(
                                    pengaduanId: pengaduan.id,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ),
      ],
    );
  }
}