import 'package:flutter/material.dart';
import '../../core/storage/secure_storage_service.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _repo = AuthRepository();
  final SecureStorageService _storage = SecureStorageService();

  UserModel? _user;
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _errorMessage;
  bool _biometricEnabled = true;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get errorMessage => _errorMessage;
  bool get biometricEnabled => _biometricEnabled;

  Future<void> initAuth() async {
    _isInitializing = true;
    notifyListeners();

    try {
      _biometricEnabled = await _storage.isBiometricEnabled();
      final profile = await _repo.getProfile();
      _user = profile;
    } catch (_) {
      _user = null;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _repo.login(email: email, password: password);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _repo.signup(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({String? name, String? phone}) async {
    try {
      final updated = await _repo.updateProfile(name: name, phone: phone);
      _user = updated;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
    try {
      final profile = await _repo.getProfile();
      if (profile != null) {
        _user = profile;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> toggleBiometric(bool value) async {
    _biometricEnabled = value;
    await _storage.setBiometricEnabled(value);
    notifyListeners();
  }

  Future<void> logout() async {
    await _repo.logout();
    _user = null;
    notifyListeners();
  }
}
