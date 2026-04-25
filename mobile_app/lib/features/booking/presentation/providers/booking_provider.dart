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

@Riverpod(keepAlive: true)
class BookingHistory extends _$BookingHistory {
  @override
  Future<List<Booking>> build() async {
    const cacheKey = 'booking_history';
    
    // 1. Check cache
    final cached = await LocalCacheService.get(cacheKey);
    if (cached != null && cached is List) {
      _refresh(cacheKey);
      return cached.map((e) => Booking.fromJson(e as Map<String, dynamic>)).toList();
    }

    // 2. Fetch fresh
    return _fetch(cacheKey);
  }

  Future<List<Booking>> _fetch(String cacheKey) async {
    final response = await ref.watch(bookingRepositoryProvider).getBookingHistory().timeout(const Duration(seconds: 15));
    return response;
  }

  Future<void> _refresh(String cacheKey) async {
    try {
      final data = await _fetch(cacheKey);
      state = AsyncData(data);
    } catch (e) {
      // Silent fail
    }
  }
}

@Riverpod(keepAlive: true)
Future<List<Map<String, dynamic>>> categoryServices(CategoryServicesRef ref, int categoryId) {
  return ref.watch(bookingRepositoryProvider).getCategoryServices(categoryId);
}
