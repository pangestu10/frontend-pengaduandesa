// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../models/pengaduan_model.dart';
import '../services/api_service.dart';

class PengaduanProvider with ChangeNotifier {
  List<Pengaduan> _pengaduanList = [];
  Pengaduan? _selectedPengaduan;
  List<Notifikasi> _notifikasiList = [];
  bool _isLoading = false;
  String? _error;
  PengaduanStats? _stats;

  List<Pengaduan> get pengaduanList => _pengaduanList;
  Pengaduan? get selectedPengaduan => _selectedPengaduan;
  List<Notifikasi> get notifikasiList => _notifikasiList;
  bool get isLoading => _isLoading;
  String? get error => _error;
  PengaduanStats? get stats => _stats;
  int get unreadNotifications => _notifikasiList.where((n) => !n.isRead).length;

  final ApiService _api = ApiService();

  Future<void> fetchPengaduan({
    String? status,
    String? kategori,
    String? search,
    bool refresh = false,
  }) async {
    _isLoading = true;
    _error = null;
    if (refresh) {
      _pengaduanList.clear();
    }
    notifyListeners();

    try {
      final response = await _api.get(
        '/pengaduan',
        queryParameters: {
          if (status != null) 'status': status,
          if (kategori != null) 'kategori': kategori,
          if (search != null && search.isNotEmpty) 'search': search,
        },
        fromJson: (json) {
          final data = json['pengaduan'] as List;
          return data.map((item) => Pengaduan.fromJson(item)).toList();
        },
      );

      if (response.success) {
        _pengaduanList = response.data ?? [];
        // Hitung statistik dari data lokal setelah fetch berhasil
        calculateStatsFromLocalData();
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'Gagal memuat pengaduan';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPengaduanById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Coba cari dari list yang sudah di-fetch terlebih dahulu
      final existingPengaduan = _pengaduanList.firstWhere(
        (p) => p.id == id,
        orElse: () => throw StateError('Not found'),
      );
      
      // Jika ditemukan di list, gunakan itu
      _selectedPengaduan = existingPengaduan;
      _isLoading = false;
      notifyListeners();
      
      // Tetap fetch dari API untuk mendapatkan data terbaru
      try {
        final response = await _api.get(
          '/pengaduan/$id',
          fromJson: (json) => Pengaduan.fromJson(json),
        );

        if (response.success && response.data != null) {
          _selectedPengaduan = response.data;
          // Update juga di list jika ada
          final index = _pengaduanList.indexWhere((p) => p.id == id);
          if (index != -1) {
            _pengaduanList[index] = response.data!;
          }
        } else {
          // Jika gagal tapi sudah ada di list, tetap gunakan yang dari list
          print('⚠️ Gagal fetch detail dari API, menggunakan data dari list');
        }
      } catch (apiError) {
        // Jika API error tapi sudah ada di list, tetap gunakan yang dari list
        print('⚠️ Error fetch dari API: $apiError, menggunakan data dari list');
      }
    } catch (e) {
      // Jika tidak ada di list, coba fetch dari API
      try {
        final response = await _api.get(
          '/pengaduan/$id',
          fromJson: (json) => Pengaduan.fromJson(json),
        );

        if (response.success) {
          _selectedPengaduan = response.data;
        } else {
          _error = response.message.isNotEmpty 
              ? response.message 
              : 'Pengaduan tidak ditemukan atau tidak memiliki akses';
        }
      } catch (apiError) {
        _error = 'Gagal memuat detail pengaduan. Pastikan Anda memiliki akses untuk melihat pengaduan ini.';
        print('❌ Error fetch pengaduan by ID: $apiError');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPengaduan({
    required String judul,
    required String deskripsi,
    required String kategori,
    String? lokasi,
    String? fotoPath,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      FormData formData = FormData.fromMap({
        'judul': judul,
        'deskripsi': deskripsi,
        'kategori': kategori,
        if (lokasi != null) 'lokasi': lokasi,
        if (fotoPath != null)
          'foto': await MultipartFile.fromFile(
            fotoPath,
            filename: fotoPath.split('/').last,
          ),
      });

      final response = await _api.upload(
        '/pengaduan',
        data: formData,
        fromJson: (json) {
          try {
            return Pengaduan.fromJson(json);
          } catch (e) {
            print('❌ Error parsing pengaduan response: $e');
            print('❌ Response data: $json');
            // Return a minimal pengaduan object if parsing fails
            // The data is already saved in backend, so we'll refresh the list
            return null;
          }
        },
      );

      print('🔍 CreatePengaduan - Response success: ${response.success}');
      print('🔍 CreatePengaduan - Response data: ${response.data != null}');
      print('🔍 CreatePengaduan - Response message: ${response.message}');

      if (response.success) {
        // Refresh the list to get the newly created pengaduan with all fields
        await fetchPengaduan(refresh: true);
        print('✅ CreatePengaduan - Pengaduan berhasil dibuat');
        return true;
      } else {
        _error = response.message.isNotEmpty 
            ? response.message 
            : 'Gagal membuat pengaduan';
        print('❌ CreatePengaduan - Error: $_error');
        return false;
      }
    } catch (e, stackTrace) {
      _error = 'Gagal membuat pengaduan: $e';
      print('❌ CreatePengaduan - Exception: $e');
      print('❌ CreatePengaduan - Stack trace: $stackTrace');
      // Even if there's an error, try to refresh the list
      // because the data might have been saved in backend
      try {
        await fetchPengaduan(refresh: true);
      } catch (_) {
        // Ignore refresh error
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ METHOD BARU: Update Pengaduan
  Future<bool> updatePengaduan({
    required int id,
    String? judul,
    String? deskripsi,
    String? kategori,
    String? lokasi,
    File? foto,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Buat FormData untuk multipart request
      FormData formData = FormData.fromMap({
        if (judul != null) 'judul': judul,
        if (deskripsi != null) 'deskripsi': deskripsi,
        if (kategori != null) 'kategori': kategori,
        if (lokasi != null) 'lokasi': lokasi,
      });

      // Tambahkan file foto jika ada
      if (foto != null) {
        formData.files.add(MapEntry(
          'foto',
          await MultipartFile.fromFile(
            foto.path,
            filename: foto.path.split('/').last,
          ),
        ));
      }

      // Gunakan method PUT untuk update
      final response = await _api.put(
        '/pengaduan/$id',
        data: formData,
        fromJson: (json) {
          try {
            return Pengaduan.fromJson(json);
          } catch (e) {
            print('❌ Error parsing update response: $e');
            print('❌ Response data: $json');
            return null;
          }
        },
        isFormData: true, // Tandai bahwa ini adalah FormData
      );

      print('🔍 UpdatePengaduan - Response success: ${response.success}');
      print('🔍 UpdatePengaduan - Response data: ${response.data != null}');
      print('🔍 UpdatePengaduan - Response message: ${response.message}');

      if (response.success) {
        // Update pengaduan dalam list
        final index = _pengaduanList.indexWhere((p) => p.id == id);
        if (index != -1 && response.data != null) {
          _pengaduanList[index] = response.data!;
        }

        // Update pengaduan yang sedang dipilih (selected)
        if (_selectedPengaduan?.id == id && response.data != null) {
          _selectedPengaduan = response.data;
        }

        // Refresh data untuk memastikan konsistensi
        await fetchPengaduanById(id);
        print('✅ UpdatePengaduan - Pengaduan berhasil diperbarui');
        return true;
      } else {
        _error = response.message.isNotEmpty 
            ? response.message 
            : 'Gagal memperbarui pengaduan';
        print('❌ UpdatePengaduan - Error: $_error');
        return false;
      }
    } catch (e, stackTrace) {
      _error = 'Gagal memperbarui pengaduan: $e';
      print('❌ UpdatePengaduan - Exception: $e');
      print('❌ UpdatePengaduan - Stack trace: $stackTrace');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStatus({
    required int id,
    required String status,
    String? tindakan,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.put(
        '/pengaduan/$id/status',
        data: {
          'status': status,
          if (tindakan != null && tindakan.isNotEmpty) 'tindakan': tindakan,
        },
        fromJson: (json) => Pengaduan.fromJson(json),
        isFormData: false,
      );

      if (response.success && response.data != null) {
        // Update in list
        final index = _pengaduanList.indexWhere((p) => p.id == id);
        if (index != -1) {
          _pengaduanList[index] = response.data!;
        }

        // Update selected pengaduan
        if (_selectedPengaduan?.id == id) {
          _selectedPengaduan = response.data;
        }

        // Hitung ulang statistik setelah update status
        calculateStatsFromLocalData();

        // Clear error karena berhasil
        _error = null;
        return true;
      } else {
        // Gunakan message dari backend langsung (tidak hardcode)
        _error = response.message.isNotEmpty 
            ? response.message 
            : 'Gagal mengupdate status pengaduan';
        return false;
      }
    } catch (e) {
      // Tangani exception dengan message yang jelas
      final errorStr = e.toString();
      
      // Jika error dari DioException, message sudah di-handle di ApiService
      // Tapi jika exception lain, berikan pesan generic
      if (errorStr.contains('DioException')) {
        // Error sudah di-handle oleh ApiService._handleError
        // Tapi kita perlu set error message dari response jika ada
        _error = 'Terjadi kesalahan saat mengupdate status';
      } else {
        _error = 'Gagal mengupdate status: Terjadi kesalahan pada server';
      }
      
      print('❌ Error updateStatus: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNotifications() async {
    try {
      final response = await _api.get(
        '/pengaduan/notifications',
        fromJson: (json) {
          final data = json as List;
          return data.map((item) => Notifikasi.fromJson(item)).toList();
        },
      );

      if (response.success) {
        _notifikasiList = response.data ?? [];
      }
    } catch (e) {
      // Silent error for notifications
    } finally {
      notifyListeners();
    }
  }

  Future<void> markNotificationsAsRead() async {
    try {
      await _api.get(
        '/pengaduan/notifications',
        queryParameters: {'mark_read': true},
      );
      
      // Update local list
      for (var notif in _notifikasiList) {
        notif.isRead = true;
      }
      notifyListeners();
    } catch (e) {
      // Silent error
    }
  }

  /// Hitung statistik dari data pengaduan lokal (client-side)
  /// Tanpa perlu memanggil backend
  void calculateStatsFromLocalData() {
    int diajukan = 0;
    int diproses = 0;
    int ditolak = 0;
    int selesai = 0;

    for (var pengaduan in _pengaduanList) {
      switch (pengaduan.status.toLowerCase()) {
        case 'diajukan':
          diajukan++;
          break;
        case 'diproses':
          diproses++;
          break;
        case 'ditolak':
          ditolak++;
          break;
        case 'selesai':
          selesai++;
          break;
      }
    }

    _stats = PengaduanStats(
      total: _pengaduanList.length,
      diajukan: diajukan,
      diproses: diproses,
      ditolak: ditolak,
      selesai: selesai,
    );

    notifyListeners();
  }

  Future<void> fetchStats() async {
    try {
      final response = await _api.get(
        '/pengaduan/stats',
        fromJson: (json) {
          final overall = json['overall'] as List;
          var stats = PengaduanStats(
            total: 0,
            diajukan: 0,
            diproses: 0,
            ditolak: 0,
            selesai: 0,
          );

          for (var item in overall) {
            switch (item['status']) {
              case 'diajukan':
                stats.diajukan = item['jumlah'];
                break;
              case 'diproses':
                stats.diproses = item['jumlah'];
                break;
              case 'ditolak':
                stats.ditolak = item['jumlah'];
                break;
              case 'selesai':
                stats.selesai = item['jumlah'];
                break;
            }
          }

          stats.total = stats.diajukan + stats.diproses + stats.ditolak + stats.selesai;
          return stats;
        },
      );

      if (response.success) {
        _stats = response.data;
      }
    } catch (e) {
      // Jika backend tidak tersedia, gunakan perhitungan dari data lokal
      calculateStatsFromLocalData();
    } finally {
      notifyListeners();
    }
  }

  void clearSelected() {
    _selectedPengaduan = null;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}