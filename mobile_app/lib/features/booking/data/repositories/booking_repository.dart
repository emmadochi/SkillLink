import '../models/booking_model.dart';
import '../../../../core/network/api_client.dart';
import 'package:dio/dio.dart';

abstract class BookingRepository {
  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> data);
  Future<List<Booking>> getBookingHistory();
  Future<bool> updateBookingStatus(int id, String status);
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
      throw e.response?.data['error'] ?? 'Network error';
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Booking>> getBookingHistory() async {
    try {
      final response = await _apiClient.getBookingHistory();
      if (response.status == 'success' && response.data != null) {
        return response.data!;
      } else {
        throw response.message ?? 'Failed to load history';
      }
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Network error';
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> updateBookingStatus(int id, String status) async {
    try {
      final response = await _apiClient.updateStatus({
        'id': id,
        'status': status,
      });
      return response.status == 'success';
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Update failed';
    } catch (e) {
      rethrow;
    }
  }
}
