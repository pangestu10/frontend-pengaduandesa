// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../providers/pengaduan_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class CreatePengaduanScreen extends StatefulWidget {
  const CreatePengaduanScreen({super.key});

  @override
  State<CreatePengaduanScreen> createState() => _CreatePengaduanScreenState();
}

class _CreatePengaduanScreenState extends State<CreatePengaduanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _lokasiController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  String _kategori = 'infrastruktur';
  File? _selectedImage;

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  // =========================
  // PICK IMAGE FROM GALLERY - SEDERHANA SEPERTI DI EDIT SCREEN
  // =========================
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (!mounted) return;
      
      // Tampilkan error yang lebih spesifik
      String errorMessage = 'Gagal mengambil gambar';
      if (e.toString().contains('Permission denied') || 
          e.toString().contains('permission')) {
        errorMessage = 'Izin akses galeri diperlukan. Silakan berikan izin di pengaturan.';
        
        // Tawarkan untuk membuka pengaturan
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Izin Diperlukan'),
            content: const Text('Aplikasi memerlukan izin untuk mengakses galeri foto. '
                'Silakan berikan izin di pengaturan.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Pengaturan'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          AppTheme.snackBar(
            content: errorMessage,
            backgroundColor: AppTheme.red,
          ),
        );
      }
    }
  }

  // =========================
  // TAKE PHOTO FROM CAMERA - SEDERHANA SEPERTI DI EDIT SCREEN
  // =========================
  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      debugPrint('Error taking photo: $e');
      if (!mounted) return;
      
      // Tampilkan error yang lebih spesifik
      String errorMessage = 'Gagal mengambil foto';
      if (e.toString().contains('Permission denied') || 
          e.toString().contains('permission')) {
        errorMessage = 'Izin kamera diperlukan. Silakan berikan izin di pengaturan.';
        
        // Tawarkan untuk membuka pengaturan
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Izin Diperlukan'),
            content: const Text('Aplikasi memerlukan izin untuk mengakses kamera. '
                'Silakan berikan izin di pengaturan.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Pengaturan'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          AppTheme.snackBar(
            content: errorMessage,
            backgroundColor: AppTheme.red,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<PengaduanProvider>(context, listen: false);

    final success = await provider.createPengaduan(
      judul: _judulController.text.trim(),
      deskripsi: _deskripsiController.text.trim(),
      kategori: _kategori,
      lokasi: _lokasiController.text.trim().isEmpty
          ? null
          : _lokasiController.text.trim(),
      fotoPath: _selectedImage?.path,
    );

    if (!mounted) return;

    if (success) {
      _judulController.clear();
      _deskripsiController.clear();
      _lokasiController.clear();

      setState(() {
        _selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        AppTheme.snackBar(
          content: 'Pengaduan berhasil dikirim',
          backgroundColor: AppTheme.green,
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        AppTheme.snackBar(
          content: provider.error ?? 'Gagal mengirim pengaduan',
          backgroundColor: AppTheme.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<PengaduanProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // Hanya warga yang boleh membuat pengaduan
    if (authProvider.isAdminOrKepalaDesa) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: const SafeArea(
            child: Center(
              child: Padding(
                padding:  EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 60,
                      color: AppTheme.white,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Hanya warga yang dapat membuat pengaduan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
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
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Buat Pengaduan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Form Container
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppTheme.glassDecoration(),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Judul Pengaduan
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: TextFormField(
                                controller: _judulController,
                                style: const TextStyle(color: AppTheme.white),
                                decoration: AppTheme.textFieldDecoration(
                                  labelText: 'Judul Pengaduan',
                                  prefixIcon: Icons.title,
                                ),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Judul tidak boleh kosong'
                                        : null,
                              ),
                            ),

                            // Kategori
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: DropdownButtonFormField<String>(
                                value: _kategori,
                                dropdownColor: AppTheme.darkPurple,
                                icon: const Icon(Icons.arrow_drop_down, color: AppTheme.white80),
                                style: const TextStyle(color: AppTheme.white),
                                decoration: InputDecoration(
                                  labelText: 'Kategori',
                                  labelStyle: const TextStyle(color: AppTheme.white80),
                                  prefixIcon: const Icon(Icons.category_outlined, color: AppTheme.white80),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: AppTheme.white30),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: AppTheme.white30),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: AppTheme.white, width: 1.5),
                                  ),
                                  filled: true,
                                  fillColor: AppTheme.white10,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'infrastruktur',
                                    child: Text('Infrastruktur', style: TextStyle(color: AppTheme.white)),
                                  ),
                                  DropdownMenuItem(
                                    value: 'sosial',
                                    child: Text('Sosial', style: TextStyle(color: AppTheme.white)),
                                  ),
                                  DropdownMenuItem(
                                    value: 'ekonomi',
                                    child: Text('Ekonomi', style: TextStyle(color: AppTheme.white)),
                                  ),
                                  DropdownMenuItem(
                                    value: 'lingkungan',
                                    child: Text('Lingkungan', style: TextStyle(color: AppTheme.white)),
                                  ),
                                  DropdownMenuItem(
                                    value: 'lainnya',
                                    child: Text('Lainnya', style: TextStyle(color: AppTheme.white)),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _kategori = value);
                                  }
                                },
                              ),
                            ),

                            // Lokasi
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: TextFormField(
                                controller: _lokasiController,
                                style: const TextStyle(color: AppTheme.white),
                                decoration: AppTheme.textFieldDecoration(
                                  labelText: 'Lokasi (opsional)',
                                  prefixIcon: Icons.location_on_outlined,
                                ),
                              ),
                            ),

                            // Deskripsi
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: TextFormField(
                                controller: _deskripsiController,
                                style: const TextStyle(color: AppTheme.white),
                                decoration: InputDecoration(
                                  labelText: 'Deskripsi',
                                  labelStyle: const TextStyle(color: AppTheme.white80),
                                  prefixIcon: const Icon(Icons.description_outlined, color: AppTheme.white80),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: AppTheme.white30),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: AppTheme.white30),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: AppTheme.white, width: 1.5),
                                  ),
                                  filled: true,
                                  fillColor: AppTheme.white10,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 16,
                                  ),
                                ),
                                maxLines: 4,
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Deskripsi tidak boleh kosong'
                                        : null,
                              ),
                            ),

                            // Foto Section
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Foto (opsional)',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (_selectedImage != null)
                                    Stack(
                                      children: [
                                        Container(
                                          height: 200,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: AppTheme.white30),
                                            borderRadius: BorderRadius.circular(12),
                                            color: AppTheme.white10,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.file(
                                              _selectedImage!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: AppTheme.red,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppTheme.red.withOpacity(0.5),
                                                  blurRadius: 8,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                            child: IconButton(
                                              onPressed: _removeImage,
                                              icon: const Icon(Icons.close, color: AppTheme.white),
                                              iconSize: 20,
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  else
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: _pickImage,
                                            icon: const Icon(Icons.photo_library, color: AppTheme.white80),
                                            label: const Text('Galeri', style: TextStyle(color: AppTheme.white80)),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              side: const BorderSide(color: AppTheme.white30),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              backgroundColor: AppTheme.white10,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: _takePhoto,
                                            icon: const Icon(Icons.camera_alt, color: AppTheme.white80),
                                            label: const Text('Kamera', style: TextStyle(color: AppTheme.white80)),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              side: const BorderSide(color: AppTheme.white30),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              backgroundColor: AppTheme.white10,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),

                            // Submit Button
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              child: Consumer<PengaduanProvider>(
                                builder: (context, provider, _) {
                                  return ElevatedButton(
                                    onPressed: provider.isLoading ? null : _submit,
                                    style: AppTheme.primaryButtonStyle,
                                    child: provider.isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppTheme.blue,
                                            ),
                                          )
                                        : Text(
                                            'KIRIM PENGADUAN',
                                            style: AppTheme.buttonTextStyle,
                                          ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}