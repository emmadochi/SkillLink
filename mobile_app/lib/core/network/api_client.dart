import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/artisan/data/models/artisan_model.dart';
import '../../features/booking/data/models/booking_model.dart';
import '../../features/settings/data/models/address_model.dart';

part 'api_client.g.dart';

class ApiClient {
  final Dio dio;

  ApiClient(this.dio, {String? baseUrl}) {
    if (baseUrl != null) dio.options.baseUrl = baseUrl;
  }

  Future<ApiResponse<AuthData>> signup(Map<String, dynamic> body) async {
    final response = await dio.post('/auth/signup', data: body);
    return _safeParse(response.data, (json) => AuthData.fromJson(json as Map<String, dynamic>));
  }

  Future<ApiResponse<AuthData>> login(Map<String, dynamic> body) async {
    final response = await dio.post('/auth/login', data: body);
    return _safeParse(response.data, (json) => AuthData.fromJson(json as Map<String, dynamic>));
  }

  Future<ApiResponse<List<Artisan>>> getArtisans({int? categoryId, double? minRating, String? query}) async {
    final response = await dio.get('/artisan', queryParameters: {
      if (categoryId != null) 'category': categoryId,
      if (minRating != null) 'rating': minRating,
      if (query != null && query.isNotEmpty) 'q': query,
    });

    return _safeParse(response.data, (json) => (json as List).map((i) => Artisan.fromJson(i as Map<String, dynamic>)).toList());
  }

  Future<ApiResponse<Artisan>> getArtisanProfile(int id) async {
    final response = await dio.get('/artisan/profile/$id');
    return _safeParse(response.data, (json) => Artisan.fromJson(json as Map<String, dynamic>));
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getCategories() async {
    final response = await dio.get('/category');
    return _safeParse(response.data, (json) => List<Map<String, dynamic>>.from(json as List));
  }

  Future<ApiResponse<Map<String, dynamic>>> createBooking(Map<String, dynamic> body) async {
    final response = await dio.post('/booking/create', data: body);
    return _safeParse(response.data, (json) => json as Map<String, dynamic>);
  }


  Future<ApiResponse<List<Booking>>> getBookingHistory() async {
    final response = await dio.get('/booking/history');
    return _safeParse(response.data, (json) => (json as List).map((i) => Booking.fromJson(i as Map<String, dynamic>)).toList());
  }

  Future<ApiResponse<Map<String, dynamic>>> updateStatus(Map<String, dynamic> body) async {
    final response = await dio.post('/booking/updateStatus', data: body);
    return _safeParse(response.data, (json) => json as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> initializePayment(Map<String, dynamic> body) async {
    final response = await dio.post('/payment/initialize', data: body);
    return _safeParse(response.data, (json) => json as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyPayment(Map<String, dynamic> body) async {
    final response = await dio.post('/payment/verify', data: body);
    return _safeParse(response.data, (json) => json as Map<String, dynamic>);
  }

  Future<ApiResponse<List<UserAddress>>> getAddresses() async {
    final response = await dio.get('/address');
    return _safeParse(response.data, (json) => (json as List).map((i) => UserAddress.fromJson(i as Map<String, dynamic>)).toList());
  }

  Future<ApiResponse<Map<String, dynamic>>> createAddress(Map<String, dynamic> body) async {
    final response = await dio.post('/address/create', data: body);
    return _safeParse(response.data, (json) => json as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> deleteAddress(int id) async {
    final response = await dio.delete('/address/delete/$id');
    return _safeParse(response.data, (json) => json as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> updateArtisanProfile(Map<String, dynamic> body) async {
    final response = await dio.post('/artisan/update', data: body);
    return _safeParse(response.data, (json) => json as Map<String, dynamic>);
  }

  ApiResponse<T> _safeParse<T>(dynamic data, T Function(Object? json) fromJsonT) {
    if (data is Map<String, dynamic>) {
      try {
        return ApiResponse.fromJson(data, fromJsonT);
      } catch (e) {
        return ApiResponse<T>(
          status: 'error',
          message: 'Failed to parse server response.',
        );
      }
    }
    return ApiResponse<T>(
      status: 'error',
      message: 'Invalid server response format.',
    );
  }
}

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final String status;
  final String? message;
  final T? data;

  ApiResponse({required this.status, this.message, this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);
}

@JsonSerializable()
class AuthData {
  final String token;
  final User user;

  AuthData({required this.token, required this.user});

  factory AuthData.fromJson(Map<String, dynamic> json) => _$AuthDataFromJson(json);
}
