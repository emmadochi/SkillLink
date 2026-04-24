import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../repositories/review_repository.dart';
import '../models/review_model.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/network/api_client.dart';

part 'review_provider.g.dart';

@riverpod
ReviewRepository reviewRepository(ReviewRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  final apiClient = ApiClient(dio);
  return ReviewRepositoryImpl(apiClient);
}

@riverpod
Future<List<Review>> artisanReviews(ArtisanReviewsRef ref, int artisanId) {
  return ref.watch(reviewRepositoryProvider).getArtisanReviews(artisanId);
}

@riverpod
class ReviewController extends _$ReviewController {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> submitReview({
    required int bookingId,
    required int rating,
    String? comment,
  }) async {
    state = const AsyncValue.loading();
    try {
      final success = await ref.read(reviewRepositoryProvider).submitReview(
        bookingId: bookingId,
        rating: rating,
        comment: comment,
      );
      if (success) {
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.error('Failed to submit review', StackTrace.current);
      }
      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}
