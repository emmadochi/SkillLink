import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../utils/location_service.dart';

part 'location_provider.g.dart';

@riverpod
class CurrentLocation extends _$CurrentLocation {
  @override
  Future<ArtisanLocation> build() async {
    try {
      final position = await LocationService.getCurrentPosition();
      if (position != null) {
        final address = await LocationService.getAddressFromLatLng(position.latitude, position.longitude);
        return ArtisanLocation(
          name: address ?? 'Lagos, Nigeria',
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }
    } catch (_) {}
    return ArtisanLocation(name: 'Lagos, Nigeria', latitude: 6.5244, longitude: 3.3792);
  }

  Future<void> detectLocation() async {
    state = const AsyncValue.loading();
    try {
      final position = await LocationService.getCurrentPosition();
      if (position != null) {
        final address = await LocationService.getAddressFromLatLng(position.latitude, position.longitude);
        state = AsyncValue.data(ArtisanLocation(
          name: address ?? 'Unknown',
          latitude: position.latitude,
          longitude: position.longitude,
        ));
      } else {
        state = AsyncValue.error('Location services disabled', StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
