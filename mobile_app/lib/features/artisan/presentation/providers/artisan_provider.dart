import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/artisan_repository.dart';
import '../../data/models/artisan_model.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/local_cache_service.dart';

part 'artisan_provider.g.dart';

@riverpod
ArtisanRepository artisanRepository(ArtisanRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  final apiClient = ApiClient(dio);
  return ArtisanRepositoryImpl(apiClient);
}

@Riverpod(keepAlive: true)
Stream<List<Artisan>> artisans(ArtisansRef ref, {int? categoryId, double? minRating, String? query, String? skills}) async* {
  final cacheKey = 'artisans_${categoryId}_${query}_$skills';
  
  // 1. Yield cached data immediately (0ms instant render)
  final cached = await LocalCacheService.get(cacheKey);
  if (cached != null && cached is List) {
    yield cached.map((e) => Artisan.fromJson(e as Map<String, dynamic>)).toList();
  }

  // 2. Fetch fresh data in background
  try {
    final response = await ref.watch(artisanRepositoryProvider).getArtisans(
      categoryId: categoryId,
      minRating: minRating,
      query: query,
      skills: skills,
    ).timeout(const Duration(seconds: 15));
    
    yield response;
  } catch (e) {
    if (cached == null) yield [];
  }
}

@Riverpod(keepAlive: true)
Stream<Artisan> artisanProfile(ArtisanProfileRef ref, int id) async* {
  final cacheKey = 'artisan_profile_$id';

  // 1. Yield cached profile immediately (0ms instant render)
  final cached = await LocalCacheService.get(cacheKey);
  if (cached != null && cached is Map<String, dynamic>) {
    try {
      yield Artisan.fromJson(cached);
    } catch (_) {}
  }

  // 2. Fetch fresh profile in background
  try {
    final response = await ref.watch(artisanRepositoryProvider).getArtisanProfile(id);
    yield response;
  } catch (e) {
    if (cached == null) {
      rethrow;
    }
  }
}

@Riverpod(keepAlive: true)
Stream<List<Artisan>> savedArtisans(SavedArtisansRef ref) async* {
  const cacheKey = 'saved_artisans';

  // 1. Yield cached list immediately
  final cached = await LocalCacheService.get(cacheKey);
  if (cached != null && cached is List) {
    try {
      yield cached.map((e) => Artisan.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {}
  }

  // 2. Fetch fresh list in background
  try {
    final response = await ref.watch(artisanRepositoryProvider).getSavedArtisans();
    yield response;
  } catch (e) {
    if (cached == null) yield [];
  }
}
