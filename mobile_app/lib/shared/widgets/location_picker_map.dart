import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink_app/core/network/location_provider.dart';
import 'package:skilllink_app/core/utils/location_service.dart';
import 'package:skilllink_app/core/theme/app_colors.dart';
import 'package:skilllink_app/shared/widgets/skilllink_button.dart';


class LocationPickerMap extends ConsumerStatefulWidget {
  const LocationPickerMap({super.key});

  @override
  ConsumerState<LocationPickerMap> createState() => _LocationPickerMapState();
}

class _LocationPickerMapState extends ConsumerState<LocationPickerMap> {
  GoogleMapController? _mapController;
  LatLng _selectedLatLng = const LatLng(6.5244, 3.3792); // Default to Lagos
  String _address = 'Loading...';
  bool _isMoving = false;

  @override
  void initState() {
    super.initState();
    final currentLoc = ref.read(currentLocationProvider).value;
    if (currentLoc != null) {
      _selectedLatLng = LatLng(currentLoc.latitude, currentLoc.longitude);
      _address = currentLoc.name;
    }
  }

  Future<void> _updateAddress(LatLng position) async {
    setState(() => _isMoving = true);
    final address = await LocationService.getAddressFromLatLng(position.latitude, position.longitude);
    if (mounted) {
      setState(() {
        _address = address ?? 'Unknown Location';
        _selectedLatLng = position;
        _isMoving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () async {
              final pos = await LocationService.getCurrentPosition();
              if (pos != null) {
                final latLng = LatLng(pos.latitude, pos.longitude);
                _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
                _updateAddress(latLng);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLatLng,
              zoom: 15,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onCameraMove: (position) {
              setState(() {
                _selectedLatLng = position.target;
                _isMoving = true;
              });
            },
            onCameraIdle: () {
              _updateAddress(_selectedLatLng);
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          // Center Marker
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 35),
              child: Icon(
                Icons.location_on_rounded,
                size: 45,
                color: AppColors.primary,
              ),
            ),
          ),
          // Address Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_pin, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _address,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_selectedLatLng.latitude.toStringAsFixed(6)}, ${_selectedLatLng.longitude.toStringAsFixed(6)}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.outline),
                  ),
                  const SizedBox(height: 24),
                  SkillLinkButton.gradient(
                    label: 'Confirm Location',
                    width: double.infinity,
                    isLoading: _isMoving,
                    onPressed: () {
                      final newLoc = ArtisanLocation(
                        name: _address,
                        latitude: _selectedLatLng.latitude,
                        longitude: _selectedLatLng.longitude,
                      );
                      ref.read(currentLocationProvider.notifier).setLocation(newLoc);
                      context.pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
