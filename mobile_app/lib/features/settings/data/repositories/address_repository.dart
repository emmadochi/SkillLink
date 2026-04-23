import '../../../../core/network/api_client.dart';
import '../models/address_model.dart';
import 'package:dio/dio.dart';

abstract class AddressRepository {
  Future<List<UserAddress>> getAddresses();
  Future<void> createAddress(UserAddress address);
  Future<void> deleteAddress(int id);
}

class AddressRepositoryImpl implements AddressRepository {
  final ApiClient _apiClient;

  AddressRepositoryImpl(this._apiClient);

  @override
  Future<List<UserAddress>> getAddresses() async {
    try {
      final response = await _apiClient.getAddresses();
      if (response.status == 'success' && response.data != null) {
        return response.data!;
      } else {
        throw response.message ?? 'Failed to load addresses';
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
  Future<void> createAddress(UserAddress address) async {
    try {
      final response = await _apiClient.createAddress(address.toJson());
      if (response.status != 'success') {
        throw response.message ?? 'Failed to add address';
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
  Future<void> deleteAddress(int id) async {
    try {
      final response = await _apiClient.deleteAddress(id);
      if (response.status != 'success') {
        throw response.message ?? 'Failed to delete address';
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
}
