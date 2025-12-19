class Env {
  // static const String baseUrl = 'http://10.0.2.2:3000/api'; // Untuk emulator Android
  // static const String baseUrl = 'http://localhost:3000/api'; // Untuk iOS/web
  static const String baseUrl = 'http://192.168.1.100:3000/api'; // Untuk device fisik
  
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}