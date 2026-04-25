import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';
import 'package:dio/dio.dart';

abstract class AuthRepository {
  Future<AuthData> signup(Map<String, dynamic> data);
  Future<AuthData> login(String email, String password);
  Future<String> uploadAvatar(String filePath);
}

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl(this._apiClient);

  @override
  Future<AuthData> signup(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.signup(data);
      if (response.status == 'success' && response.data != null) {
        return response.data!;
      } else {
        throw response.message ?? 'Signup failed';
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        throw responseData['error'] ?? responseData['message'] ?? 'Network error';
      }
      throw 'Server error: ${e.response?.statusCode ?? "Unknown error"}';
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthData> login(String email, String password) async {
    try {
      final response = await _apiClient.login({
        'email': email,
        'password': password,
      });
      if (response.status == 'success' && response.data != null) {
        return response.data!;
      } else {
        throw response.message ?? 'Login failed';
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        throw responseData['error'] ?? responseData['message'] ?? 'Invalid credentials';
      }
      throw 'Server error: ${e.response?.statusCode ?? "Unknown error"}';
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> uploadAvatar(String filePath) async {
    try {
      final response = await _apiClient.uploadAvatar(filePath);
      if (response.status == 'success' && response.data != null) {
        return response.data!['avatar_url'];
      } else {
        throw response.message ?? 'Upload failed';
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        throw responseData['error'] ?? responseData['message'] ?? 'Upload error';
      }
      if (e.response != null) {
        throw 'Server error: ${e.response!.statusCode}';
      }
      throw 'Upload failed: ${e.type.toString().split('.').last} - ${e.message ?? 'Unknown network error'}';
    } catch (e) {
      rethrow;
    }
  }
}
