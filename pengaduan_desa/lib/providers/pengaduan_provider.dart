import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
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
      final response = await _api.get(
        '/pengaduan/$id',
        fromJson: (json) => Pengaduan.fromJson(json),
      );

      if (response.success) {
        _selectedPengaduan = response.data;
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'Gagal memuat detail pengaduan';
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
          if (tindakan != null) 'tindakan': tindakan,
        },
        fromJson: (json) => Pengaduan.fromJson(json),
      );

      if (response.success) {
        // Update in list
        final index = _pengaduanList.indexWhere((p) => p.id == id);
        if (index != -1) {
          _pengaduanList[index] = response.data!;
        }

        // Update selected
        if (_selectedPengaduan?.id == id) {
          _selectedPengaduan = response.data;
        }

        return true;
      } else {
        _error = response.message;
        return false;
      }
    } catch (e) {
      _error = 'Gagal mengupdate status';
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
      // Silent error for stats
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