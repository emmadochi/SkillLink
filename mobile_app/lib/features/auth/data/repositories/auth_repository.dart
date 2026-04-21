import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';
import 'package:dio/dio.dart';

abstract class AuthRepository {
  Future<AuthData> signup(Map<String, dynamic> data);
  Future<AuthData> login(String email, String password);
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
      throw e.response?.data['error'] ?? 'Network error';
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
      throw e.response?.data['error'] ?? 'Invalid credentials';
    } catch (e) {
      rethrow;
    }
  }
}
