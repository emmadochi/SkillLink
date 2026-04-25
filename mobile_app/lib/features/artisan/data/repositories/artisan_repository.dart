import '../models/artisan_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/local_cache_service.dart';
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
    final cacheKey = 'artisans_${categoryId}_${query}_$skills';
    
    try {
      final response = await _apiClient.getArtisans(
        categoryId: categoryId,
        minRating: minRating,
        query: query,
        skills: skills,
      );

      if (response.status == 'success' && response.data != null) {
        // Save to cache
        await LocalCacheService.set(cacheKey, response.data!.map((e) => e.toJson()).toList());
        return response.data!;
      } else {
        throw response.message ?? 'Failed to fetch artisans';
      }
    } catch (e) {
      // Try to get from cache on error (network failure)
      final cached = await LocalCacheService.get(cacheKey);
      if (cached != null && cached is List) {
        return cached.map((e) => Artisan.fromJson(e as Map<String, dynamic>)).toList();
      }
      rethrow;
    }
  }

  @override
  Future<Artisan> getArtisanProfile(int id) async {
    final cacheKey = 'artisan_profile_$id';
    try {
      final response = await _apiClient.getArtisanProfile(id);
      if (response.status == 'success' && response.data != null) {
        await LocalCacheService.set(cacheKey, response.data!.toJson());
        return response.data!;
      } else {
        throw response.message ?? 'Profile not found';
      }
    } catch (e) {
      final cached = await LocalCacheService.get(cacheKey);
      if (cached != null && cached is Map<String, dynamic>) {
        return Artisan.fromJson(cached);
      }
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
    const cacheKey = 'saved_artisans';
    try {
      final response = await _apiClient.getSavedArtisans();
      if (response.status == 'success' && response.data != null) {
        await LocalCacheService.set(cacheKey, response.data!.map((e) => e.toJson()).toList());
        return response.data!;
      }
      return [];
    } catch (e) {
      final cached = await LocalCacheService.get(cacheKey);
      if (cached != null && cached is List) {
        return cached.map((e) => Artisan.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    }
  }
}
