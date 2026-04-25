import '../models/artisan_model.dart';
import '../../../../core/network/api_client.dart';
import 'package:dio/dio.dart';

abstract class ArtisanRepository {
  Future<List<Artisan>> getArtisans({int? categoryId, double? minRating, String? query, String? skills});
  Future<Artisan> getArtisanProfile(int id);
  Future<bool> updateArtisanProfile(Map<String, dynamic> data);
  Future<bool> toggleSaveArtisan(int id);
  Future<List<Artisan>> getSavedArtisans();
}

class ArtisanRepositoryImpl implements ArtisanRepository {
  final ApiClient _apiClient;

  ArtisanRepositoryImpl(this._apiClient);

  @override
  Future<List<Artisan>> getArtisans({int? categoryId, double? minRating, String? query, String? skills}) async {
    try {
      final response = await _apiClient.getArtisans(
        categoryId: categoryId,
        minRating: minRating,
        query: query,
        skills: skills,
      );

      if (response.status == 'success' && response.data != null) {
        return response.data!;
      } else {
        throw response.message ?? 'Failed to fetch artisans';
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
  Future<Artisan> getArtisanProfile(int id) async {
    try {
      final response = await _apiClient.getArtisanProfile(id);
      if (response.status == 'success' && response.data != null) {
        return response.data!;
      } else {
        throw response.message ?? 'Profile not found';
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
  Future<bool> updateArtisanProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.updateArtisanProfile(data);
      return response.status == 'success';
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        throw responseData['error'] ?? responseData['message'] ?? 'Update error';
      }
      throw 'Server error';
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> toggleSaveArtisan(int id) async {
    try {
      final response = await _apiClient.toggleSaveArtisan(id);
      return response.status == 'success';
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Artisan>> getSavedArtisans() async {
    try {
      final response = await _apiClient.getSavedArtisans();
      if (response.status == 'success' && response.data != null) {
        return response.data!;
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
