import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/local_cache_service.dart';
import '../../data/models/category_model.dart';

part 'category_provider.g.dart';

@Riverpod(keepAlive: true)
@Riverpod(keepAlive: true)
Stream<List<Category>> categories(CategoriesRef ref) async* {
  const cacheKey = 'categories_list';
  
  // 1. Yield cached data immediately if available
  final cached = await LocalCacheService.get(cacheKey);
  if (cached != null && cached is List) {
    yield cached.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
  }

  // 2. Fetch fresh data from network
  final dio = ref.watch(dioProvider);
  final client = ApiClient(dio);
  
  try {
    final response = await client.getCategories().timeout(const Duration(seconds: 15));
    if (response.status == 'success' && response.data != null) {
      final list = response.data!.map((e) => Category.fromJson(e)).toList();
      await LocalCacheService.set(cacheKey, response.data!);
      yield list;
    }
  } catch (e) {
    // If network fails and we haven't yielded anything yet, yield empty list
    if (cached == null) yield [];
  }
}

@riverpod
Future<List<Map<String, dynamic>>> categoryServices(CategoryServicesRef ref, int categoryId) async {
  final dio = ref.watch(dioProvider);
  final client = ApiClient(dio);
  
  final response = await client.getCategoryServices(categoryId);
  if (response.status == 'success' && response.data != null) {
    return response.data!;
  }
  return [];
}
