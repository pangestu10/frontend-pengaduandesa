// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:pengaduan_desa/services/api_service.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  // ===== Helpers RBAC (Role-Based Access Control) =====
  /// Get role dari user (langsung dari database via backend)
  /// Backend sekarang sudah membaca role dari database, bukan dari token
  String get role {
    final userRole = _user?.role ?? 'warga';
    
    // Log role yang digunakan untuk debugging
    print('👤 AuthProvider.role - Role dari user object: $userRole');
    
    // Workaround fallback berdasarkan email (hanya untuk safety, seharusnya tidak diperlukan lagi)
    // Karena backend sudah membaca role dari database dengan benar
    if (_user?.email != null && userRole.toLowerCase() == 'warga') {
      final email = _user!.email.toLowerCase();
      
      // Hanya gunakan fallback jika benar-benar diperlukan (untuk backward compatibility)
      if ((email.contains('kepaladesa') || email.contains('kepala_desa'))) {
        print('⚠️ Role dari backend masih "warga" untuk email kepala desa, menggunakan fallback: kepala_desa');
        print('⚠️ PERHATIAN: Pastikan backend sudah menyimpan role dengan benar di database');
        return 'kepala_desa';
      }
      
      if (email.contains('admin')) {
        print('⚠️ Role dari backend masih "warga" untuk email admin, menggunakan fallback: admin');
        print('⚠️ PERHATIAN: Pastikan backend sudah menyimpan role dengan benar di database');
        return 'admin';
      }
    }
    
    return userRole;
  }

  String get _normalizedRole =>
      role.toLowerCase().trim().replaceAll(' ', '_');

  bool get isAdmin => _normalizedRole == 'admin';

  bool get isKepalaDesa => _normalizedRole == 'kepala_desa';

  bool get isWarga => _normalizedRole == 'warga' || _normalizedRole.isEmpty;

  bool get isAdminOrKepalaDesa => isAdmin || isKepalaDesa;

  final AuthService _authService = AuthService();
  final StorageService _storage = StorageService();

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    await _storage.init();
    final token = _storage.getToken();
    final userData = _storage.getUserData();

    if (token != null && userData != null) {
      ApiService().setToken(token);
      _user = User.fromJson(userData);
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  /// Login user dan simpan token + data user ke storage.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      print('🔐 Login response: ${response.success}');
      print('🔐 Login data: ${response.data}');

      if (response.success && response.data != null) {
        final loginData = response.data!;
        final token = loginData.token;
        final user = loginData.user;

        print('👤 User dari API - Role: ${user.role}, Email: ${user.email}');

        await _storage.init();
        await _storage.saveToken(token);
        await _storage.saveUserData(user.toJson());

        ApiService().setToken(token);

        _user = user;
        _isAuthenticated = true;

        // Log role setelah set user
        print('✅ Login berhasil.');
        print('   📋 Role dari backend: ${_user?.role}');
        print('   📋 Role setelah normalisasi: $role');
        print('   📋 isAdmin: $isAdmin');
        print('   📋 isKepalaDesa: $isKepalaDesa');
        print('   📋 isAdminOrKepalaDesa: $isAdminOrKepalaDesa');
        
        return true;
      } else {
        _error = response.message;
        print('❌ Login gagal: $_error');
        return false;
      }
    } catch (e) {
      _error = 'Login gagal: $e';
      print('❌ Login exception: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ambil profil user dari API dan update state.
  Future<void> getUserProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.getProfile();

      print('📋 Profile response: ${response.success}');
      print('📋 Profile data: ${response.data?.toJson()}');

      if (response.success && response.data != null) {
        _user = response.data;
        await _storage.saveUserData(_user!.toJson());
        print('✅ Profile loaded. Role: ${_user?.role}');
      } else {
        _error = response.message;
        print('❌ Profile error: $_error');
      }
    } catch (e) {
      _error = 'Gagal memuat profil: $e';
      print('❌ Profile exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String nik,
    required String nama,
    required String email,
    required String password,
    required String role,
    String? telepon,
    String? alamat,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    print('👤 AuthProvider.register - Role yang diterima: $role');
    print('👤 AuthProvider.register - Email: $email');

    try {
      final response = await _authService.register(
        nik: nik,
        nama: nama,
        email: email,
        password: password,
        role: role,
        telepon: telepon,
        alamat: alamat,
      );

      print('👤 AuthProvider.register - Response success: ${response.success}');
      print('👤 AuthProvider.register - Response message: ${response.message}');
      
      if (response.success) {
        // Backend sekarang sudah menyimpan role dengan benar di database
        // Response register biasanya tidak mengembalikan data user lengkap
        // User perlu login setelah register untuk mendapatkan token dengan role yang benar
        print('✅ Registrasi berhasil');
        print('   📋 Role yang dikirim ke backend: $role');
        print('   💡 Silakan login untuk mendapatkan token dengan role yang benar dari database');
        
        // Jika backend mengembalikan data user, log untuk debugging
        if (response.data != null) {
          print('👤 AuthProvider.register - Response data: ${response.data}');
          
          if (response.data is Map<String, dynamic>) {
            final userData = response.data as Map<String, dynamic>;
            final returnedRole = userData['role'] ?? userData['user']?['role'];
            if (returnedRole != null) {
              print('👤 AuthProvider.register - Role dari backend response: $returnedRole');
              
              if (returnedRole != role) {
                print('⚠️ PERINGATAN: Role yang dikirim ($role) berbeda dengan role yang dikembalikan backend ($returnedRole)');
                print('⚠️ Pastikan backend menyimpan role dengan benar di database');
              } else {
                print('✅ Role yang dikirim dan dikembalikan backend sama: $role');
              }
            }
          }
        }
        
        return true;
      } else {
        _error = response.message.isNotEmpty 
            ? response.message 
            : 'Registrasi gagal';
        print('❌ AuthProvider.register - Error: $_error');
        return false;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
      print('❌ AuthProvider.register - Exception: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh token untuk mendapatkan token baru dengan role terbaru dari database
  Future<bool> refreshToken() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.refreshToken();

      if (response.success && response.data != null) {
        final loginData = response.data!;
        final token = loginData.token;
        final user = loginData.user;

        await _storage.init();
        await _storage.saveToken(token);
        await _storage.saveUserData(user.toJson());

        ApiService().setToken(token);

        _user = user;
        _isAuthenticated = true;

        print('✅ Token berhasil di-refresh. Role: ${_user?.role}');
        return true;
      } else {
        _error = response.message.isNotEmpty 
            ? response.message 
            : 'Gagal refresh token';
        print('❌ Refresh token gagal: $_error');
        return false;
      }
    } catch (e) {
      _error = 'Gagal refresh token: $e';
      print('❌ Refresh token exception: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    await _storage.clearAll();
    ApiService().clearToken();
    
    _user = null;
    _isAuthenticated = false;
    _isLoading = false;
    
    notifyListeners();
  }

  Future<void> updateProfile({
    String? nama,
    String? telepon,
    String? alamat,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.updateProfile(
        nama: nama,
        telepon: telepon,
        alamat: alamat,
      );

      if (response.success) {
        _user = response.data;
        await _storage.saveUserData(_user!.toJson());
      }
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}