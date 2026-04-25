import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/artisan_repository.dart';
import '../../data/models/artisan_model.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/network/api_client.dart';

part 'artisan_provider.g.dart';

@riverpod
ArtisanRepository artisanRepository(ArtisanRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  final apiClient = ApiClient(dio);
  return ArtisanRepositoryImpl(apiClient);
}

@Riverpod(keepAlive: true)
class Artisans extends _$Artisans {
  @override
  Future<List<Artisan>> build({int? categoryId, double? minRating, String? query, String? skills}) async {
    final cacheKey = 'artisans_${categoryId}_${query}_$skills';
    
    // 1. Check cache
    final cached = await LocalCacheService.get(cacheKey);
    if (cached != null && cached is List) {
      _refresh(cacheKey, categoryId, minRating, query, skills);
      return cached.map((e) => Artisan.fromJson(e as Map<String, dynamic>)).toList();
    }

    // 2. Fetch fresh
    return _fetch(cacheKey, categoryId, minRating, query, skills);
  }

  Future<List<Artisan>> _fetch(String cacheKey, int? categoryId, double? minRating, String? query, String? skills) async {
    final response = await ref.watch(artisanRepositoryProvider).getArtisans(
      categoryId: categoryId,
      minRating: minRating,
      query: query,
      skills: skills,
    ).timeout(const Duration(seconds: 15));
    
    return response;
  }

  Future<void> _refresh(String cacheKey, int? categoryId, double? minRating, String? query, String? skills) async {
    try {
      final data = await _fetch(cacheKey, categoryId, minRating, query, skills);
      state = AsyncData(data);
    } catch (e) {
      // Silent fail
    }
  }
}

@Riverpod(keepAlive: true)
Future<Artisan> artisanProfile(ArtisanProfileRef ref, int id) {
  return ref.watch(artisanRepositoryProvider).getArtisanProfile(id);
}

@Riverpod(keepAlive: true)
Future<List<Artisan>> savedArtisans(SavedArtisansRef ref) {
  return ref.watch(artisanRepositoryProvider).getSavedArtisans();
}
