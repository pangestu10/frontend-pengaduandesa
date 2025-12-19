import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';

class UserProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List<User> _users = [];
  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get(
        ApiConstants.users,
        fromJson: (json) {
          final data = json['users'] as List;
          return data.map((e) => User.fromJson(e)).toList();
        },
      );

      if (response.success) {
        _users = response.data ?? [];
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'Gagal memuat data pengguna';
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


