import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/local_cache_service.dart';
import '../../data/models/category_model.dart';

part 'category_provider.g.dart';

@Riverpod(keepAlive: true)
Future<List<Category>> categories(CategoriesRef ref) async {
  final dio = ref.watch(dioProvider);
  final client = ApiClient(dio);
  const cacheKey = 'categories_list';
  
  try {
    final response = await client.getCategories();
    if (response.status == 'success' && response.data != null) {
      final list = response.data!.map((e) => Category.fromJson(e)).toList();
      await LocalCacheService.set(cacheKey, response.data!);
      return list;
    }
    return [];
  } catch (e) {
    final cached = await LocalCacheService.get(cacheKey);
    if (cached != null && cached is List) {
      return cached.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
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
