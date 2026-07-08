import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_constants.dart';

enum LocationPermissionStatus {
  loading,
  ready,
  serviceDisabled,
  denied,
  deniedForever,
  failed,
}

class LocationState {
  final LatLng position;
  final LocationPermissionStatus permissionStatus;
  final String error;

  LocationState({
    required this.position,
    this.permissionStatus = LocationPermissionStatus.loading,
    this.error = '',
  });

  LocationState copyWith({
    LatLng? position,
    LocationPermissionStatus? permissionStatus,
    String? error,
  }) {
    return LocationState(
      position: position ?? this.position,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      error: error ?? this.error,
    );
  }
}

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier()
      : super(LocationState(
          position: AppConstants.defaultLocation,
          permissionStatus: LocationPermissionStatus.loading,
        )) {
    determinePosition();
  }

  Future<void> determinePosition() async {
    state = state.copyWith(permissionStatus: LocationPermissionStatus.loading, error: '');

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          permissionStatus: LocationPermissionStatus.serviceDisabled,
          error: 'Location services are disabled. Please enable them.',
        );
        return;
      }

      final permission = await Geolocator.checkPermission();
      await _handlePermission(permission);
    } catch (e) {
      state = state.copyWith(
        permissionStatus: LocationPermissionStatus.failed,
        error: 'Failed to get location. Please try again.',
      );
    }
  }

  Future<void> requestLocationPermission() async {
    state = state.copyWith(permissionStatus: LocationPermissionStatus.loading, error: '');

    final permission = await Geolocator.requestPermission();
    await _handlePermission(permission);
  }

  Future<void> _handlePermission(LocationPermission permission) async {
    if (permission == LocationPermission.denied) {
      state = state.copyWith(
        permissionStatus: LocationPermissionStatus.denied,
        error: 'Location permission is required to show the map.',
      );
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      state = state.copyWith(
        permissionStatus: LocationPermissionStatus.deniedForever,
        error: 'Location permission is permanently denied. Open app settings to allow it.',
      );
      return;
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      final position = await Geolocator.getCurrentPosition();
      state = state.copyWith(
        position: LatLng(position.latitude, position.longitude),
        permissionStatus: LocationPermissionStatus.ready,
      );
      return;
    }

    state = state.copyWith(
      permissionStatus: LocationPermissionStatus.failed,
      error: 'Unable to acquire location permission.',
    );
  }
}
