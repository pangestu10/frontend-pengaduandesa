// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pengaduan_provider.dart';
import '../../models/pengaduan_model.dart';

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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Di sisi backend, gunakan endpoint update pengaduan jika ada.
    // Di sini kita hanya memanggil fetchPengaduan ulang setelah kembali.
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PengaduanProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Pengaduan'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _judulController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Pengaduan',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Judul tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _kategori,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'infrastruktur',
                      child: Text('Infrastruktur'),
                    ),
                    DropdownMenuItem(
                      value: 'sosial',
                      child: Text('Sosial'),
                    ),
                    DropdownMenuItem(
                      value: 'ekonomi',
                      child: Text('Ekonomi'),
                    ),
                    DropdownMenuItem(
                      value: 'lingkungan',
                      child: Text('Lingkungan'),
                    ),
                    DropdownMenuItem(
                      value: 'lainnya',
                      child: Text('Lainnya'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _kategori = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lokasiController,
                  decoration: const InputDecoration(
                    labelText: 'Lokasi (opsional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _deskripsiController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Deskripsi tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : _save,
                    child: const Text('SIMPAN PERUBAHAN'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


