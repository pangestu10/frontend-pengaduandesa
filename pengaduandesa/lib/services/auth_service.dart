import 'package:pengaduan_desa/models/api_response.dart';
import '../models/user_model.dart';
import './api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<ApiResponse<LoginResponse>> login({
    required String email,  
    required String password,
  }) async {
    return await _api.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
      fromJson: (json) => LoginResponse.fromJson(json),
    );
  }

  Future<ApiResponse<dynamic>> register({
    required String nik,
    required String nama,
    required String email,
    required String password,
    required String role,
    String? telepon,
    String? alamat,
  }) async {
    final requestData = {
      'nik': nik,
      'nama': nama,
      'email': email,
      'password': password,
      'role': role,
      if (telepon != null && telepon.isNotEmpty) 'telepon': telepon,
      if (alamat != null && alamat.isNotEmpty) 'alamat': alamat,
    };
    
    ('📝 Register Request - Role yang dikirim: $role');
    ('📝 Register Request - Data lengkap: $requestData');
    
    final response = await _api.post(
      '/auth/register',
      data: requestData,
    );
    
    ('📝 Register Response - Success: ${response.success}');
    ('📝 Register Response - Message: ${response.message}');
    ('📝 Register Response - Data: ${response.data}');
    
    return response;
  }

  Future<ApiResponse<User>> getProfile() async {
    return await _api.get(
      '/auth/profile',
      fromJson: (json) => User.fromJson(json),
    );
  }

  Future<ApiResponse<User>> updateProfile({
    String? nama,
    String? telepon,
    String? alamat,
    String? fotoProfil,
  }) async {
    return await _api.put(
      '/auth/profile',
      data: {
        'nama': nama,
        'telepon': telepon,
        'alamat': alamat,
        'foto_profil': fotoProfil,
      },
      fromJson: (json) => User.fromJson(json),
      isFormData: false, // TAMBAHKAN INI - karena ini JSON biasa
    );
  }

  Future<ApiResponse<dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await _api.put(
      '/auth/change-password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
      isFormData: false,
    );
  }

  /// Refresh token untuk mendapatkan token baru dengan role terbaru dari database
  Future<ApiResponse<LoginResponse>> refreshToken() async {
    return await _api.post(
      '/auth/refresh-token',
      data: {},
      fromJson: (json) => LoginResponse.fromJson(json),
    );
  }
}