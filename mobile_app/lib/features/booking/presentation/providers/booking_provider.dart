import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/models/booking_model.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/local_cache_service.dart';

part 'booking_provider.g.dart';

@riverpod
BookingRepository bookingRepository(BookingRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  final apiClient = ApiClient(dio);
  return BookingRepositoryImpl(apiClient);
}

@Riverpod(keepAlive: true)
Stream<List<Booking>> bookingHistory(BookingHistoryRef ref) async* {
  const cacheKey = 'booking_history';
  
  // 1. Yield cached data immediately
  final cached = await LocalCacheService.get(cacheKey);
  if (cached != null && cached is List) {
    yield cached.map((e) => Booking.fromJson(e as Map<String, dynamic>)).toList();
  }

  // 2. Fetch fresh
  try {
    final response = await ref.watch(bookingRepositoryProvider).getBookingHistory().timeout(const Duration(seconds: 15));
    yield response;
  } catch (e) {
    if (cached == null) yield [];
  }
}

@Riverpod(keepAlive: true)
Future<List<Map<String, dynamic>>> categoryServices(CategoryServicesRef ref, int categoryId) {
  return ref.watch(bookingRepositoryProvider).getCategoryServices(categoryId);
}
