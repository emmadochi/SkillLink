import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'api_client.dart';
import 'dio_provider.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/artisan/data/repositories/artisan_repository.dart';
import '../../features/booking/data/repositories/booking_repository.dart';
import '../../features/payment/data/repositories/payment_repository.dart';

part 'api_providers.g.dart';

@riverpod
ApiClient apiClient(ApiClientRef ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  final client = ref.watch(apiClientProvider);
  return AuthRepositoryImpl(client);
}

@riverpod
ArtisanRepository artisanRepository(ArtisanRepositoryRef ref) {
  final client = ref.watch(apiClientProvider);
  return ArtisanRepositoryImpl(client);
}

@riverpod
BookingRepository bookingRepository(BookingRepositoryRef ref) {
  final client = ref.watch(apiClientProvider);
  return BookingRepositoryImpl(client);
}

@riverpod
PaymentRepository paymentRepository(PaymentRepositoryRef ref) {
  final client = ref.watch(apiClientProvider);
  return PaymentRepositoryImpl(client);
}
