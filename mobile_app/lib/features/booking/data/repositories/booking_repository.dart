import '../models/booking_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/local_cache_service.dart';
import 'package:dio/dio.dart';

abstract class BookingRepository {
  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> data);
  Future<List<Booking>> getBookingHistory();
  Future<bool> updateBookingStatus(int id, String status, {String? reason});
  Future<bool> negotiateBooking(int id, double price, String status);
  Future<List<Map<String, dynamic>>> getCategoryServices(int categoryId);
}

class BookingRepositoryImpl implements BookingRepository {
  final ApiClient _apiClient;

  BookingRepositoryImpl(this._apiClient);

  @override
  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.createBooking(data);
      if (response.status == 'success' && response.data != null) {
        return response.data!;
      } else {
        throw response.message ?? 'Booking failed';
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        throw responseData['error'] ?? responseData['message'] ?? 'Booking failed';
      }
      throw 'Server error: ${e.response?.statusCode ?? "Unknown error"}';
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Booking>> getBookingHistory() async {
    const cacheKey = 'booking_history';
    try {
      final response = await _apiClient.getBookingHistory();
      if (response.status == 'success' && response.data != null) {
        await LocalCacheService.set(cacheKey, response.data!.map((e) => e.toJson()).toList());
        return response.data!;
      } else {
        throw response.message ?? 'Failed to load history';
      }
    } catch (e) {
      final cached = await LocalCacheService.get(cacheKey);
      if (cached != null && cached is List) {
        return cached.map((e) => Booking.fromJson(e as Map<String, dynamic>)).toList();
      }
      rethrow;
    }
  }

  @override
  Future<bool> updateBookingStatus(int id, String status, {String? reason}) async {
    try {
      final response = await _apiClient.updateStatus({
        'id': id,
        'status': status,
        if (reason != null) 'reason': reason,
      });
      return response.status == 'success';
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        throw responseData['error'] ?? responseData['message'] ?? 'Update failed';
      }
      throw 'Server error';
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> negotiateBooking(int id, double price, String status) async {
    try {
      final response = await _apiClient.negotiate({
        'id': id,
        'price': price,
        'status': status,
      });
      return response.status == 'success';
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        throw responseData['error'] ?? responseData['message'] ?? 'Negotiation failed';
      }
      throw 'Server error';
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCategoryServices(int categoryId) async {
    final cacheKey = 'cat_services_$categoryId';
    try {
      final response = await _apiClient.getCategoryServices(categoryId);
      if (response.status == 'success' && response.data != null) {
        await LocalCacheService.set(cacheKey, response.data!);
        return response.data!;
      } else {
        return [];
      }
    } catch (e) {
      final cached = await LocalCacheService.get(cacheKey);
      if (cached != null && cached is List) {
        return List<Map<String, dynamic>>.from(cached);
      }
      return [];
    }
  }
}
