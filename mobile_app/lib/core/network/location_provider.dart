import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../utils/location_service.dart';

part 'location_provider.g.dart';

@riverpod
class CurrentLocation extends _$CurrentLocation {
  @override
  Future<String> build() async {
    try {
      final position = await LocationService.getCurrentPosition();
      if (position != null) {
        final address = await LocationService.getAddressFromLatLng(position);
        if (address != null) return address;
      }
    } catch (_) {}
    return 'Lagos, Nigeria'; // Fallback if detection fails
  }

  Future<void> detectLocation() async {
    state = const AsyncValue.loading();
    try {
      final position = await LocationService.getCurrentPosition();
      if (position != null) {
        final address = await LocationService.getAddressFromLatLng(position);
        if (address != null) {
          state = AsyncValue.data(address);
          return;
        }
      }
      state = const AsyncValue.data('Location unavailable');
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
