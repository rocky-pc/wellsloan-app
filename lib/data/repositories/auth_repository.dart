import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _client;
  final SecureStorageService _storage = SecureStorageService();

  AuthRepository({ApiClient? client}) : _client = client ?? ApiClient();

  Future<UserModel> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _client.post(
      ApiEndpoints.signup,
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );

    final data = response.data;
    final token = data['token'];
    if (token != null) {
      await _storage.saveToken(token);
    }

    return UserModel.fromJson(data['user']);
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data;
    final token = data['token'];
    if (token != null) {
      await _storage.saveToken(token);
    }

    return UserModel.fromJson(data['user']);
  }

  Future<UserModel?> getProfile() async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) return null;

    final response = await _client.get(ApiEndpoints.me);
    final data = response.data;
    return UserModel.fromJson(data['user']);
  }

  Future<UserModel> updateProfile({String? name, String? phone}) async {
    final response = await _client.patch(
      ApiEndpoints.me,
      data: {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
      },
    );
    return UserModel.fromJson(response.data['user']);
  }

  Future<void> logout() async {
    try {
      await _client.post(ApiEndpoints.logout);
    } catch (_) {}
    await _storage.deleteToken();
  }
}
