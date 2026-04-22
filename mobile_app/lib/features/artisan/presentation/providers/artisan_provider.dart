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

@riverpod
Future<List<Artisan>> artisans(ArtisansRef ref, {int? categoryId, double? minRating}) {
  return ref.watch(artisanRepositoryProvider).getArtisans(
    categoryId: categoryId,
    minRating: minRating,
  );
}

@riverpod
Future<Artisan> artisanProfile(ArtisanProfileRef ref, int id) {
  return ref.watch(artisanRepositoryProvider).getArtisanProfile(id);
}
