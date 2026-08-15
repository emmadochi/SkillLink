import '../../../../core/network/api_client.dart';
import '../models/review_model.dart';

abstract class ReviewRepository {
  Future<List<Review>> getArtisanReviews(int artisanId);
  Future<bool> submitReview({
    required int bookingId,
    required int rating,
    String? comment,
    List<String>? qualityTags,
    String? beforePhotoUrl,
    String? afterPhotoUrl,
  });
  Future<String?> uploadReviewPhoto(String filePath);
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
    List<String>? qualityTags,
    String? beforePhotoUrl,
    String? afterPhotoUrl,
  }) async {
    final response = await _apiClient.submitReview({
      'booking_id': bookingId,
      'rating': rating,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
      if (qualityTags != null && qualityTags.isNotEmpty) 'quality_tags': qualityTags,
      if (beforePhotoUrl != null) 'before_photo_url': beforePhotoUrl,
      if (afterPhotoUrl != null) 'after_photo_url': afterPhotoUrl,
    });
    return response.status == 'success';
  }

  @override
  Future<String?> uploadReviewPhoto(String filePath) async {
    final response = await _apiClient.uploadReviewPhoto(filePath);
    if (response.status == 'success' && response.data != null) {
      return response.data!['photo_url']?.toString();
    }
    return null;
  }
}
