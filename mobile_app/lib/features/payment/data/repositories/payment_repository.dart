import '../../../../core/network/api_client.dart';
import 'package:dio/dio.dart';

abstract class PaymentRepository {
  Future<Map<String, dynamic>> initializePayment(int bookingId, double amount);
  Future<bool> verifyPayment(String reference);
}

class PaymentRepositoryImpl implements PaymentRepository {
  final ApiClient _apiClient;

  PaymentRepositoryImpl(this._apiClient);

  @override
  Future<Map<String, dynamic>> initializePayment(int bookingId, double amount) async {
    try {
      final response = await _apiClient.initializePayment({
        'booking_id': bookingId,
        'amount': amount,
      });
      if (response.status == 'success' && response.data != null) {
        return response.data!;
      } else {
        throw response.message ?? 'Payment initialization failed';
      }
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Network error';
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> verifyPayment(String reference) async {
    try {
      final response = await _apiClient.verifyPayment({
        'reference': reference,
      });
      return response.status == 'success';
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Verification failed';
    } catch (e) {
      rethrow;
    }
  }
}
