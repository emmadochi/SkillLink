import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/location_service.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/providers/user_provider.dart';
import '../../../artisan/presentation/providers/artisan_provider.dart';

class BookingLiveTrackingMap extends ConsumerStatefulWidget {
  final int bookingId;
  final String status;
  final String? artisanName;
  final String? artisanPhone;
  final double? initialArtisanLat;
  final double? initialArtisanLng;
  final double? customerLat;
  final double? customerLng;

  const BookingLiveTrackingMap({
    super.key,
    required this.bookingId,
    required this.status,
    this.artisanName,
    this.artisanPhone,
    this.initialArtisanLat,
    this.initialArtisanLng,
    this.customerLat,
    this.customerLng,
  });

  @override
  ConsumerState<BookingLiveTrackingMap> createState() => _BookingLiveTrackingMapState();
}

class _BookingLiveTrackingMapState extends ConsumerState<BookingLiveTrackingMap> {
  GoogleMapController? _mapController;
  Timer? _trackingTimer;
  Timer? _artisanBroadcastTimer;

  LatLng? _artisanLocation;
  LatLng? _customerLocation;
  double? _distanceKm;
  bool _isBroadcasting = false;
  bool _isLoading = true;
  String? _lastUpdatedTime;

  @override
  void initState() {
    super.initState();
    // Default Lagos coords fallback if missing
    _artisanLocation = LatLng(
      widget.initialArtisanLat ?? 6.5244,
      widget.initialArtisanLng ?? 3.3792,
    );
    _customerLocation = LatLng(
      widget.customerLat ?? 6.5355,
      widget.customerLng ?? 3.3920,
    );

    _fetchLiveTracking();
    _startPeriodicTracking();
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    _artisanBroadcastTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _startPeriodicTracking() {
    _trackingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted && (widget.status == 'confirmed' || widget.status == 'arrived' || widget.status == 'in_progress')) {
        _fetchLiveTracking();
      }
    });
  }

  Future<void> _fetchLiveTracking() async {
    try {
      final dio = ref.read(dioProvider);
      final client = ApiClient(dio);
      final response = await client.getLiveTracking(
        widget.bookingId,
        destLat: _customerLocation?.latitude,
        destLng: _customerLocation?.longitude,
      );

      if (response.status == 'success' && response.data != null && mounted) {
        final data = response.data!;
        final artisan = data['artisan'] as Map<String, dynamic>?;
        final dist = data['distance_km'];

        setState(() {
          if (artisan != null && artisan['latitude'] != null && artisan['longitude'] != null) {
            _artisanLocation = LatLng(
              (artisan['latitude'] as num).toDouble(),
              (artisan['longitude'] as num).toDouble(),
            );
            _lastUpdatedTime = artisan['last_update']?.toString();
          }
          if (dist != null) {
            _distanceKm = (dist as num).toDouble();
          }
          _isLoading = false;
        });

        _fitBounds();
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _fitBounds() {
    if (_mapController == null || _artisanLocation == null || _customerLocation == null) return;

    final southWestLat = _artisanLocation!.latitude < _customerLocation!.latitude
        ? _artisanLocation!.latitude
        : _customerLocation!.latitude;
    final southWestLng = _artisanLocation!.longitude < _customerLocation!.longitude
        ? _artisanLocation!.longitude
        : _customerLocation!.longitude;

    final northEastLat = _artisanLocation!.latitude > _customerLocation!.latitude
        ? _artisanLocation!.latitude
        : _customerLocation!.latitude;
    final northEastLng = _artisanLocation!.longitude > _customerLocation!.longitude
        ? _artisanLocation!.longitude
        : _customerLocation!.longitude;

    final bounds = LatLngBounds(
      southwest: LatLng(southWestLat - 0.005, southWestLng - 0.005),
      northeast: LatLng(northEastLat + 0.005, northEastLng + 0.005),
    );

    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  Future<void> _toggleArtisanLiveBroadcast() async {
    if (_isBroadcasting) {
      _artisanBroadcastTimer?.cancel();
      setState(() => _isBroadcasting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Live GPS broadcasting paused.')),
        );
      }
      return;
    }

    setState(() => _isBroadcasting = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Live GPS broadcasting active. Transmitting location...'),
          backgroundColor: Color(0xFF0A6E3A),
        ),
      );
    }

    // Initial broadcast
    await _sendCurrentLocationUpdate();

    // Stream every 8 seconds
    _artisanBroadcastTimer = Timer.periodic(const Duration(seconds: 8), (_) async {
      await _sendCurrentLocationUpdate();
    });
  }

  Future<void> _sendCurrentLocationUpdate() async {
    try {
      final pos = await LocationService.getCurrentPosition();
      if (pos != null && mounted) {
        final repo = ref.read(artisanRepositoryProvider);
        await repo.updateLiveLocation(
          latitude: pos.latitude,
          longitude: pos.longitude,
          heading: pos.heading,
          speed: pos.speed,
        );
        setState(() {
          _artisanLocation = LatLng(pos.latitude, pos.longitude);
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userStateProvider).value;
    final isArtisanUser = user?.role == 'artisan';

    final markers = <Marker>{};

    if (_artisanLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('artisan_marker'),
          position: _artisanLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(
            title: widget.artisanName ?? 'Artisan Location',
            snippet: _distanceKm != null ? '${_distanceKm!.toStringAsFixed(1)} km away' : 'On route',
          ),
        ),
      );
    }

    if (_customerLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('customer_marker'),
          position: _customerLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: const InfoWindow(
            title: 'Service Destination',
            snippet: 'Customer Site',
          ),
        ),
      );
    }

    final polylines = <Polyline>{};
    if (_artisanLocation != null && _customerLocation != null) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route_polyline'),
          points: [_artisanLocation!, _customerLocation!],
          color: AppColors.surfaceTint,
          width: 4,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceVariant.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _artisanLocation ?? const LatLng(6.5244, 3.3792),
                zoom: 14,
              ),
              markers: markers,
              polylines: polylines,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              onMapCreated: (controller) {
                _mapController = controller;
                _fitBounds();
              },
            ),

            // Top Status Overlay Pill
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _isBroadcasting || widget.status == 'arrived' || widget.status == 'in_progress'
                            ? const Color(0xFF10B981)
                            : AppColors.surfaceTint,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.status == 'arrived'
                            ? 'Artisan Has Arrived at Site'
                            : (widget.status == 'in_progress'
                                ? 'Service In Progress'
                                : 'Artisan En Route / Travelling'),
                        style: AppTypography.labelMd.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    if (_distanceKm != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_distanceKm!.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Floating Controls
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  // Artisan Broadcast toggle button (if artisan)
                  if (isArtisanUser) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _toggleArtisanLiveBroadcast,
                        icon: Icon(
                          _isBroadcasting ? Icons.gps_fixed_rounded : Icons.gps_not_fixed_rounded,
                          size: 18,
                        ),
                        label: Text(
                          _isBroadcasting ? 'GPS Active (Streaming)' : 'Start GPS Broadcast',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isBroadcasting ? const Color(0xFF0A6E3A) : AppColors.surfaceTint,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Customer: Refresh Location Button
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _lastUpdatedTime != null ? 'Live tracking active' : 'Live map connected',
                              style: AppTypography.labelSm.copyWith(color: AppColors.outline),
                            ),
                            InkWell(
                              onTap: () {
                                _fetchLiveTracking();
                                _fitBounds();
                              },
                              child: const Row(
                                children: [
                                  Icon(Icons.my_location_rounded, size: 14, color: AppColors.surfaceTint),
                                  SizedBox(width: 4),
                                  Text(
                                    'Recenter',
                                    style: TextStyle(
                                      color: AppColors.surfaceTint,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
