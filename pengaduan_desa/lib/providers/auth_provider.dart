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

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    _isAuthenticated = false; // Reset authentication state
    notifyListeners();

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      // Debug print
      print('🔍 AuthProvider - Response success: ${response.success}');
      print('🔍 AuthProvider - Response data: ${response.data != null}');
      print('🔍 AuthProvider - Response message: ${response.message}');

      // Check if login is successful
      if (response.success && response.data != null) {
        try {
          _user = response.data!.user;
          await _storage.saveToken(response.data!.token);
          await _storage.saveUserData(response.data!.user.toJson());
          ApiService().setToken(response.data!.token);
          _isAuthenticated = true;
          _error = null;
          print('✅ AuthProvider - Login successful, isAuthenticated: $_isAuthenticated');
        } catch (parseError) {
          _isAuthenticated = false;
          _error = 'Error parsing response: $parseError';
          print('❌ AuthProvider - Parse error: $parseError');
          print('❌ AuthProvider - Stack trace: ${StackTrace.current}');
        }
      } else {
        _isAuthenticated = false;
        _error = response.message.isNotEmpty 
            ? response.message 
            : 'Login gagal. Silakan coba lagi.';
        print('❌ AuthProvider - Login failed: $_error');
      }
    } catch (e, stackTrace) {
      _isAuthenticated = false;
      _error = 'Terjadi kesalahan: $e';
      print('❌ AuthProvider - Exception: $e');
      print('❌ AuthProvider - Stack trace: $stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    print('🔍 AuthProvider - Returning isAuthenticated: $_isAuthenticated');
    return _isAuthenticated;
  }

  Future<bool> register({
    required String nik,
    required String nama,
    required String email,
    required String password,
    String? telepon,
    String? alamat,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.register(
        nik: nik,
        nama: nama,
        email: email,
        password: password,
        telepon: telepon,
        alamat: alamat,
      );

      if (response.success) {
        return true;
      } else {
        _error = response.message;
        return false;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
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