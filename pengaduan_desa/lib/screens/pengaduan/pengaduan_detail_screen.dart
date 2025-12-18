import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/env.dart';
import '../../providers/pengaduan_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_widget.dart';

class PengaduanDetailScreen extends StatefulWidget {
  final int pengaduanId;

  const PengaduanDetailScreen({
    super.key,
    required this.pengaduanId,
  });

  @override
  State<PengaduanDetailScreen> createState() => _PengaduanDetailScreenState();
}

class _PengaduanDetailScreenState extends State<PengaduanDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPengaduanDetail();
    });
  }

  Future<void> _loadPengaduanDetail() async {
    final provider = Provider.of<PengaduanProvider>(context, listen: false);
    await provider.fetchPengaduanById(widget.pengaduanId);
  }

  Future<void> _updateStatus(String status, {String? tindakan}) async {
    final provider = Provider.of<PengaduanProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.user?.role != 'admin' &&
        authProvider.user?.role != 'kepala_desa') {
      return;
    }

    String? inputTindakan = tindakan;
    
    if (status == 'ditolak' || status == 'selesai') {
      inputTindakan = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              status == 'ditolak' 
                  ? 'Alasan Penolakan' 
                  : 'Tindakan yang Dilakukan',
            ),
            content: TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Masukkan keterangan...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                inputTindakan = value;
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, inputTindakan),
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      );
    }

    if (inputTindakan == null && (status == 'ditolak' || status == 'selesai')) {
      return;
    }

    final success = await provider.updateStatus(
      id: widget.pengaduanId,
      status: status,
      tindakan: inputTindakan,
    );

    if (!mounted) return;

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status berhasil diupdate'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PengaduanProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final pengaduan = provider.selectedPengaduan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengaduan'),
      ),
      body: provider.isLoading && pengaduan == null
          ? const LoadingWidget()
          : pengaduan == null
              ? const Center(child: Text('Pengaduan tidak ditemukan'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: pengaduan.statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: pengaduan.statusColor,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          pengaduan.statusText,
                          style: TextStyle(
                            color: pengaduan.statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Judul
                      Text(
                        pengaduan.judul,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Info pengaduan
                      Row(
                        children: [
                          const Icon(Icons.category, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            pengaduan.kategoriText,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(pengaduan.tanggalDiajukan),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Lokasi
                      if (pengaduan.lokasi != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Lokasi:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(pengaduan.lokasi!),
                            const SizedBox(height: 16),
                          ],
                        ),

                      // Deskripsi
                      const Text(
                        'Deskripsi:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pengaduan.deskripsi,
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 24),

                      // Foto
                      if (pengaduan.foto != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Foto:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                '${Env.baseUrl.replaceFirst('/api', '')}${pengaduan.foto!}',
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: double.infinity,
                                    height: 200,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.broken_image,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),

                      // Informasi Pelapor
                      const Text(
                        'Informasi Pelapor:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue[100],
                          child: Text(
                            pengaduan.pelaporNama?.isNotEmpty == true
                                ? pengaduan.pelaporNama![0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ),
                        title: Text(pengaduan.pelaporNama ?? 'Tidak diketahui'),
                        subtitle: Text(pengaduan.pelaporNik ?? ''),
                      ),
                      const SizedBox(height: 24),

                      // Tindakan (jika ada)
                      if (pengaduan.tindakan != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tindakan:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green[100]!),
                              ),
                              child: Text(pengaduan.tindakan!),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),

                      // Tombol Aksi untuk Admin/Kepala Desa
                      if (authProvider.user?.role == 'admin' ||
                          authProvider.user?.role == 'kepala_desa')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            const SizedBox(height: 16),
                            const Text(
                              'Aksi:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (pengaduan.status == 'diajukan')
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () =>
                                          _updateStatus('diproses'),
                                      child: const Text('Proses'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () =>
                                          _updateStatus('ditolak'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(color: Colors.red),
                                      ),
                                      child: const Text('Tolak'),
                                    ),
                                  ),
                                ],
                              ),
                            if (pengaduan.status == 'diproses')
                              ElevatedButton(
                                onPressed: () => _updateStatus('selesai'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: const Text('Tandai Selesai'),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}