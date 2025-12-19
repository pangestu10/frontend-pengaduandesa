// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:pengaduan_desa/models/pengaduan_model.dart' show Pengaduan;
import 'package:provider/provider.dart';
import '../../config/env.dart';
import '../../providers/pengaduan_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/loading_widget.dart';
import 'edit_pengaduan_screen.dart';

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

    // Gunakan helper isAdminOrKepalaDesa yang sudah ada fallback dari email
    if (!authProvider.isAdminOrKepalaDesa) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        AppTheme.snackBar(
          content: 'Anda tidak memiliki izin untuk mengubah status pengaduan',
          backgroundColor: AppTheme.red,
        ),
      );
      return;
    }

    String? inputTindakan = tindakan;
    
    // Minta input tindakan jika status memerlukan
    if (status == 'ditolak' || status == 'selesai') {
      inputTindakan = await showDialog<String>(
        context: context,
        builder: (context) {
          String? tempTindakan = '';
          return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                backgroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        status == 'ditolak' 
                            ? 'Alasan Penolakan' 
                            : 'Tindakan yang Dilakukan',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        maxLines: 4,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: status == 'ditolak' 
                              ? 'Masukkan alasan penolakan...' 
                              : 'Masukkan tindakan yang telah dilakukan...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppTheme.blue),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) {
                          tempTindakan = value;
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              if (tempTindakan != null && tempTindakan!.trim().isNotEmpty) {
                                Navigator.pop(context, tempTindakan);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.blue,
                            ),
                            child: const Text('Simpan'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }

    // Validasi: jika status memerlukan tindakan tapi tidak diisi, batalkan
    if ((status == 'ditolak' || status == 'selesai') && 
        (inputTindakan == null || inputTindakan.trim().isEmpty)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        AppTheme.snackBar(
          content: status == 'ditolak' 
              ? 'Alasan penolakan harus diisi' 
              : 'Tindakan yang dilakukan harus diisi',
          backgroundColor: AppTheme.red,
        ),
      );
      return;
    }

    // Tampilkan loading indicator
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Panggil update status
    final success = await provider.updateStatus(
      id: widget.pengaduanId,
      status: status,
      tindakan: inputTindakan?.trim(),
    );

    // Tutup loading indicator
    if (mounted) {
      Navigator.pop(context);
    }

    if (!mounted) return;

    if (success) {
      // Tampilkan snackbar sukses
      ScaffoldMessenger.of(context).showSnackBar(
        AppTheme.snackBar(
          content: 'Status pengaduan berhasil diperbarui',
          backgroundColor: AppTheme.green,
        ),
      );
      
      // Auto-refresh detail setelah update berhasil
      await _loadPengaduanDetail();
    } else {
      // Tampilkan error dari backend (jangan hardcode)
      final errorMsg = provider.error ?? 'Gagal mengupdate status pengaduan';
      
      ScaffoldMessenger.of(context).showSnackBar(
        AppTheme.snackBar(
          content: errorMsg,
          backgroundColor: AppTheme.red,
          duration: const Duration(seconds: 4), // Durasi lebih lama untuk error
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
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppTheme.headerGradient,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppTheme.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Detail Pengaduan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: provider.isLoading && pengaduan == null
                    ? const LoadingWidget(
                        message: 'Memuat detail pengaduan...',
                        textColor: AppTheme.white,
                      )
                    : pengaduan == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: AppTheme.white.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Pengaduan tidak ditemukan',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppTheme.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: AppTheme.glassDecoration(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Status Badge
                                    Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              pengaduan.statusColor,
                                              pengaduan.statusColor.withOpacity(0.7),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: pengaduan.statusColor.withOpacity(0.3),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _getStatusIcon(pengaduan.status),
                                              color: AppTheme.white,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              pengaduan.statusText.toUpperCase(),
                                              style: const TextStyle(
                                                color: AppTheme.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Judul
                                    Text(
                                      pengaduan.judul,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.white,
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Informasi Meta
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.white10,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          _buildMetaInfo(
                                            icon: Icons.category,
                                            text: pengaduan.kategoriText,
                                            color: AppTheme.white,
                                          ),
                                          const SizedBox(width: 20),
                                          _buildMetaInfo(
                                            icon: Icons.calendar_today,
                                            text: _formatDate(pengaduan.tanggalDiajukan),
                                            color: AppTheme.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Informasi Lokasi
                                    if (pengaduan.lokasi != null)
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildSectionTitle('Lokasi Kejadian'),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: AppTheme.white10,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_on,
                                                  color: AppTheme.white80,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    pengaduan.lokasi!,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: AppTheme.white80,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                        ],
                                      ),

                                    // Deskripsi
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildSectionTitle('Deskripsi'),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppTheme.white10,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            pengaduan.deskripsi,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppTheme.white80,
                                              height: 1.6,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    ),

                                    // Foto Bukti
                                    if (pengaduan.foto != null)
                                      _buildFotoSection(pengaduan),

                                    // Informasi Pelapor
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildSectionTitle('Informasi Pelapor'),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppTheme.white10,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient: LinearGradient(
                                                    colors: [AppTheme.white, AppTheme.primaryColor.withOpacity(0.5)],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.person,
                                                  color: AppTheme.blue,
                                                  size: 24,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      pengaduan.pelaporNama ?? 'Tidak diketahui',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                        color: AppTheme.white,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'NIK: ${pengaduan.pelaporNik ?? 'Tidak tersedia'}',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: AppTheme.white80,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    ),

                                    // Tindakan (jika ada)
                                    if (pengaduan.tindakan != null)
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildSectionTitle('Tindakan'),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: AppTheme.green.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(
                                                color: AppTheme.green.withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              pengaduan.tindakan!,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: AppTheme.white,
                                                height: 1.6,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                        ],
                                      ),

                                    // Tombol Aksi untuk Admin/Kepala Desa
                                    if (authProvider.isAdminOrKepalaDesa) ...[
                                      _buildSectionTitle('Kelola Status Pengaduan'),
                                      const SizedBox(height: 12),
                                      
                                      if (pengaduan.status == 'diajukan')
                                        Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () => _updateStatus('diproses'),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: AppTheme.blue,
                                                      foregroundColor: AppTheme.white,
                                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      elevation: 4,
                                                    ),
                                                    child: const Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(Icons.play_arrow, size: 20),
                                                        SizedBox(width: 8),
                                                        Text('PROSES', style: TextStyle(fontWeight: FontWeight.w600)),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () => _updateStatus('ditolak'),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: AppTheme.red,
                                                      foregroundColor: AppTheme.white,
                                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      elevation: 4,
                                                    ),
                                                    child: const Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(Icons.close, size: 20),
                                                        SizedBox(width: 8),
                                                        Text('TOLAK', style: TextStyle(fontWeight: FontWeight.w600)),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      
                                      if (pengaduan.status == 'diproses')
                                        ElevatedButton(
                                          onPressed: () => _updateStatus('selesai'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.green,
                                            foregroundColor: AppTheme.white,
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            elevation: 4,
                                            minimumSize: const Size(double.infinity, 50),
                                          ),
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.check_circle, size: 20),
                                              SizedBox(width: 8),
                                              Text('TANDAI SELESAI', style: TextStyle(fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                        ),
                                      const SizedBox(height: 20),
                                    ],

                                    // Tombol Edit untuk Pemilik Pengaduan (Warga)
                                    if (authProvider.user?.role == 'warga' && 
                                        authProvider.user?.nik == pengaduan.pelaporNik) ...[
                                      const SizedBox(height: 20),
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: AppTheme.white10,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppTheme.white20,
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Kelola Pengaduan Anda',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: AppTheme.white,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => EditPengaduanScreen(
                                                      pengaduan: pengaduan,
                                                    ),
                                                  ),
                                                ).then((value) {
                                                  if (value == true) {
                                                    // Refresh detail setelah edit
                                                    _loadPengaduanDetail();
                                                  }
                                                });
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.orange,
                                                foregroundColor: AppTheme.white,
                                                padding: const EdgeInsets.symmetric(vertical: 14),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                minimumSize: const Size(double.infinity, 50),
                                              ),
                                              icon: const Icon(Icons.edit, size: 20),
                                              label: const Text('EDIT PENGADUAN'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk menampilkan foto dengan desain menarik
  Widget _buildFotoSection(Pengaduan pengaduan) {
    final fotoUrl = '${Env.baseUrl.replaceFirst('/api', '')}${pengaduan.foto!}';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Foto Bukti'),
        const SizedBox(height: 8),
        
        // Container utama untuk foto
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Gambar dengan rounded corners
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  height: 240,
                  width: double.infinity,
                  color: AppTheme.white10,
                  child: Image.network(
                    fotoUrl,
                    width: double.infinity,
                    height: 240,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: AppTheme.white,
                          strokeWidth: 2,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.white10,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo,
                              size: 60,
                              color: AppTheme.white30,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Gagal memuat foto',
                              style: TextStyle(
                                color: AppTheme.white60,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Overlay gradient di bagian bawah
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              
              // Label "BUKTI"
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.white30,
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 14,
                        color: AppTheme.white,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'BUKTI FOTO',
                        style: TextStyle(
                          color: AppTheme.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Tombol Zoom
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => _showFullScreenImage(fotoUrl),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.white30,
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.zoom_in,
                      size: 20,
                      color: AppTheme.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Info foto
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.white10,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: AppTheme.white70,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tap tombol zoom untuk melihat foto lebih jelas',
                  style: TextStyle(
                    color: AppTheme.white70,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // Method untuk menampilkan foto full screen
  void _showFullScreenImage(String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            // Background dengan blur effect
            Container(
              color: Colors.black,
              child: Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: AppTheme.white,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: 60,
                              color: AppTheme.white70,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Gagal memuat foto',
                              style: TextStyle(
                                color: AppTheme.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            
            // Tombol close
            Positioned(
              top: 40,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.white30,
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: AppTheme.white,
                    size: 28,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            
            // Instruksi
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: Colors.black.withOpacity(0.5),
                child: const Text(
                  'Pinch untuk zoom • Drag untuk bergerak • Tap di luar untuk keluar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.white,
      ),
    );
  }

  Widget _buildMetaInfo({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'diajukan':
        return Icons.access_time;
      case 'diproses':
        return Icons.play_arrow;
      case 'selesai':
        return Icons.check_circle;
      case 'ditolak':
        return Icons.close;
      default:
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hari ini ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Kemarin ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
}