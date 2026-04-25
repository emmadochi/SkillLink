import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/local_cache_service.dart';
import '../../data/models/category_model.dart';

part 'category_provider.g.dart';

@Riverpod(keepAlive: true)
class Categories extends _$Categories {
  @override
  Future<List<Category>> build() async {
    const cacheKey = 'categories_list';
    
    // 1. Check cache
    final cached = await LocalCacheService.get(cacheKey);
    if (cached != null && cached is List) {
      // Trigger background refresh
      _refresh(cacheKey);
      return cached.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
    }

    // 2. No cache, fetch fresh
    return _fetch(cacheKey);
  }

  Future<List<Category>> _fetch(String cacheKey) async {
    final dio = ref.watch(dioProvider);
    final client = ApiClient(dio);
    
    final response = await client.getCategories().timeout(const Duration(seconds: 15));
    if (response.status == 'success' && response.data != null) {
      final list = response.data!.map((e) => Category.fromJson(e)).toList();
      await LocalCacheService.set(cacheKey, response.data!);
      return list;
    }
    return [];
  }

  Future<void> _refresh(String cacheKey) async {
    try {
      final data = await _fetch(cacheKey);
      state = AsyncData(data);
    } catch (e) {
      // Silent fail on background refresh
    }
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
