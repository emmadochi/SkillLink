import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/models/booking_model.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/network/api_client.dart';

part 'booking_provider.g.dart';

@riverpod
BookingRepository bookingRepository(BookingRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  final apiClient = ApiClient(dio);
  return BookingRepositoryImpl(apiClient);
}

@riverpod
Future<List<Booking>> bookingHistory(BookingHistoryRef ref) {
  return ref.watch(bookingRepositoryProvider).getBookingHistory();
}
