import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token
  Future<void> saveToken(String token) async {
    await _prefs.setString('token', token);
  }

  String? getToken() {
    return _prefs.getString('token');
  }

  Future<void> removeToken() async {
    await _prefs.remove('token');
  }

  // User Data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _prefs.setString('user_data', json.encode(userData));
  }

  Map<String, dynamic>? getUserData() {
    final data = _prefs.getString('user_data');
    if (data != null) {
      return json.decode(data);
    }
    return null;
  }

  Future<void> removeUserData() async {
    await _prefs.remove('user_data');
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}