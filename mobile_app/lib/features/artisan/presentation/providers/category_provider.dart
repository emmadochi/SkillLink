import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/network/api_client.dart';
import '../../data/models/category_model.dart';

part 'category_provider.g.dart';

@riverpod
Future<List<Category>> categories(CategoriesRef ref) async {
  final dio = ref.watch(dioProvider);
  final client = ApiClient(dio);
  
  final response = await client.getCategories();
  if (response.status == 'success' && response.data != null) {
    return response.data!.map((e) => Category.fromJson(e)).toList();
  }
  return [];
}
