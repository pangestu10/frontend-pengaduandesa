class ApiConstants {
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/auth/profile';
  static const String changePassword = '/auth/change-password';
  
  static const String pengaduan = '/pengaduan';
  static const String pengaduanStats = '/pengaduan/stats';
  static const String notifications = '/pengaduan/notifications';
  static const String kepalaDesa = '/pengaduan/kepala-desa';
  
  static const String users = '/users';
  
  static Map<String, String> getAuthHeader(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}