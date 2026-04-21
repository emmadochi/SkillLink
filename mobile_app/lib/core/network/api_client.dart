import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/artisan/data/models/artisan_model.dart';
import '../../features/booking/data/models/booking_model.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @POST('/auth/signup')
  Future<ApiResponse<AuthData>> signup(@Body() Map<String, dynamic> body);

  @POST('/auth/login')
  Future<ApiResponse<AuthData>> login(@Body() Map<String, dynamic> body);

  @GET('/artisan')
  Future<ApiResponse<List<Artisan>>> getArtisans({
    @Query('category') int? categoryId,
    @Query('rating') double? minRating,
  });

  @GET('/artisan/profile/{id}')
  Future<ApiResponse<Artisan>> getArtisanProfile(@Path('id') int id);

  @GET('/category')
  Future<ApiResponse<List<Map<String, dynamic>>>> getCategories();

  // Booking Endpoints
  @POST('/booking/create')
  Future<ApiResponse<Map<String, dynamic>>> createBooking(@Body() Map<String, dynamic> body);

  @GET('/booking/history')
  Future<ApiResponse<List<Booking>>> getBookingHistory();

  @POST('/booking/updateStatus')
  Future<ApiResponse<Map<String, dynamic>>> updateStatus(@Body() Map<String, dynamic> body);

  // Payment Endpoints
  @POST('/payment/initialize')
  Future<ApiResponse<Map<String, dynamic>>> initializePayment(@Body() Map<String, dynamic> body);

  @POST('/payment/verify')
  Future<ApiResponse<Map<String, dynamic>>> verifyPayment(@Body() Map<String, dynamic> body);
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
