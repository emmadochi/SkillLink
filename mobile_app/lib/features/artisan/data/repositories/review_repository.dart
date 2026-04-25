import '../../../../core/network/api_client.dart';
import '../models/review_model.dart';

abstract class ReviewRepository {
  Future<List<Review>> getArtisanReviews(int artisanId);
  Future<bool> submitReview({
    required int bookingId,
    required int rating,
    String? comment,
  });
}

class ReviewRepositoryImpl implements ReviewRepository {
  final ApiClient _apiClient;

  ReviewRepositoryImpl(this._apiClient);

  @override
  Future<List<Review>> getArtisanReviews(int artisanId) async {
    final response = await _apiClient.getArtisanReviews(artisanId);
    if (response.status == 'success' && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message ?? 'Failed to fetch reviews');
  }

  @override
  Future<bool> submitReview({
    required int bookingId,
    required int rating,
    String? comment,
  }) async {
    final response = await _apiClient.submitReview({
      'booking_id': bookingId,
      'rating': rating,
      'comment': comment,
    });
    return response.status == 'success';
  }
}
