import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/artisan/data/models/artisan_model.dart';
import '../../features/booking/data/models/booking_model.dart';

part 'api_client.g.dart';

class ApiClient {
  final Dio dio;

  ApiClient(this.dio, {String? baseUrl}) {
    if (baseUrl != null) dio.options.baseUrl = baseUrl;
  }

  Future<ApiResponse<AuthData>> signup(Map<String, dynamic> body) async {
    final response = await dio.post('/auth/signup', data: body);
    return ApiResponse.fromJson(response.data, (json) => AuthData.fromJson(json as Map<String, dynamic>));
  }

  Future<ApiResponse<AuthData>> login(Map<String, dynamic> body) async {
    final response = await dio.post('/auth/login', data: body);
    return ApiResponse.fromJson(response.data, (json) => AuthData.fromJson(json as Map<String, dynamic>));
  }

  Future<ApiResponse<List<Artisan>>> getArtisans({int? categoryId, double? minRating}) async {
    final response = await dio.get('/artisan', queryParameters: {
      if (categoryId != null) 'category': categoryId,
      if (minRating != null) 'rating': minRating,
    });
    return ApiResponse.fromJson(response.data, (json) => (json as List).map((i) => Artisan.fromJson(i as Map<String, dynamic>)).toList());
  }

  Future<ApiResponse<Artisan>> getArtisanProfile(int id) async {
    final response = await dio.get('/artisan/profile/$id');
    return ApiResponse.fromJson(response.data, (json) => Artisan.fromJson(json as Map<String, dynamic>));
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getCategories() async {
    final response = await dio.get('/category');
    return ApiResponse.fromJson(response.data, (json) => List<Map<String, dynamic>>.from(json as List));
  }

  Future<ApiResponse<Map<String, dynamic>>> createBooking(Map<String, dynamic> body) async {
    final response = await dio.post('/booking/create', data: body);
    return ApiResponse.fromJson(response.data, (json) => json as Map<String, dynamic>);
  }

  Future<ApiResponse<List<Booking>>> getBookingHistory() async {
    final response = await dio.get('/booking/history');
    return ApiResponse.fromJson(response.data, (json) => (json as List).map((i) => Booking.fromJson(i as Map<String, dynamic>)).toList());
  }

  Future<ApiResponse<Map<String, dynamic>>> updateStatus(Map<String, dynamic> body) async {
    final response = await dio.post('/booking/updateStatus', data: body);
    return ApiResponse.fromJson(response.data, (json) => json as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> initializePayment(Map<String, dynamic> body) async {
    final response = await dio.post('/payment/initialize', data: body);
    return ApiResponse.fromJson(response.data, (json) => json as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyPayment(Map<String, dynamic> body) async {
    final response = await dio.post('/payment/verify', data: body);
    return ApiResponse.fromJson(response.data, (json) => json as Map<String, dynamic>);
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
