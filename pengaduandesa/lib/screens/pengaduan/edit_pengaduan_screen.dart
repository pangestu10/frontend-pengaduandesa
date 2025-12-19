// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/pengaduan_provider.dart';
import '../../models/pengaduan_model.dart';
import '../../theme/app_theme.dart';

class EditPengaduanScreen extends StatefulWidget {
  final Pengaduan pengaduan;

  const EditPengaduanScreen({
    super.key,
    required this.pengaduan,
  });

  @override
  State<EditPengaduanScreen> createState() => _EditPengaduanScreenState();
}

class _EditPengaduanScreenState extends State<EditPengaduanScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulController;
  late TextEditingController _deskripsiController;
  late TextEditingController _lokasiController;
  late String _kategori;
  File? _selectedFoto;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.pengaduan.judul);
    _deskripsiController =
        TextEditingController(text: widget.pengaduan.deskripsi);
    _lokasiController =
        TextEditingController(text: widget.pengaduan.lokasi ?? '');
    _kategori = widget.pengaduan.kategori;
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedFoto = File(image.path);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<PengaduanProvider>(context, listen: false);

    final success = await provider.updatePengaduan(
      id: widget.pengaduan.id,
      judul: _judulController.text,
      deskripsi: _deskripsiController.text,
      kategori: _kategori,
      lokasi: _lokasiController.text.isNotEmpty ? _lokasiController.text : null,
      foto: _selectedFoto,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppTheme.snackBar(
          content: 'Pengaduan berhasil diperbarui',
          backgroundColor: AppTheme.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        AppTheme.snackBar(
          content: 'Gagal memperbarui pengaduan',
          backgroundColor: AppTheme.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final provider = Provider.of<PengaduanProvider>(context);

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
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Edit Pengaduan',
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppTheme.glassDecoration(),
                      child: Form(
                        key: _formKey,
                        child: Column(
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
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Judul tidak boleh kosong';
                                  }
                                  return null;
                                },
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
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
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
                                  if (value == null) return;
                                  setState(() {
                                    _kategori = value;
                                  });
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
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  alignLabelWithHint: true,
                                ),
                                maxLines: 4,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Deskripsi tidak boleh kosong';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            // Upload Foto
                            Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Foto Bukti (opsional)',
                                    style: TextStyle(
                                      color: AppTheme.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _selectedFoto != null
                                        ? 'Foto baru dipilih'
                                        : widget.pengaduan.foto != null
                                            ? 'Foto lama tetap digunakan'
                                            : 'Belum ada foto',
                                    style: const TextStyle(
                                      color: AppTheme.white80,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    onPressed: _pickImage,
                                    icon: const Icon(Icons.camera_alt, color: AppTheme.white80),
                                    label: const Text('Pilih Foto', style: TextStyle(color: AppTheme.white80)),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: AppTheme.white10,
                                      foregroundColor: AppTheme.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: const BorderSide(
                                          color: AppTheme.white30,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Tombol Simpan
                            Consumer<PengaduanProvider>(
                              builder: (context, provider, _) {
                                return ElevatedButton(
                                  onPressed: provider.isLoading ? null : _save,
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
                                          'SIMPAN PERUBAHAN',
                                          style: AppTheme.buttonTextStyle,
                                        ),
                                );
                              },
                            ),
                          ],
                        ),
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
}