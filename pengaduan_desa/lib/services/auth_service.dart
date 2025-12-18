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
    String? telepon,
    String? alamat,
  }) async {
    return await _api.post(
      '/auth/register',
      data: {
        'nik': nik,
        'nama': nama,
        'email': email,
        'password': password,
        'telepon': telepon,
        'alamat': alamat,
      },
    );
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
    );
  }
}