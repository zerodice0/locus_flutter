import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:locus_flutter/core/services/location/location_service.dart';
import 'package:locus_flutter/core/services/map/map_service.dart';

// LocationService 인스턴스 제공
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationServiceImpl();
});

// 현재 위치 상태를 관리하는 Provider
final currentLocationProvider = StateNotifierProvider<CurrentLocationNotifier, AsyncValue<UniversalLatLng?>>((ref) {
  final locationService = ref.read(locationServiceProvider);
  return CurrentLocationNotifier(locationService);
});

// 위치 권한 상태를 관리하는 Provider
final locationPermissionProvider = StateNotifierProvider<LocationPermissionNotifier, AsyncValue<PermissionStatus>>((ref) {
  final locationService = ref.read(locationServiceProvider);
  return LocationPermissionNotifier(locationService);
});

// 위치 서비스 활성화 상태를 관리하는 Provider
final locationServiceEnabledProvider = FutureProvider<bool>((ref) async {
  final locationService = ref.read(locationServiceProvider);
  return await locationService.isLocationServiceEnabled();
});

class CurrentLocationNotifier extends StateNotifier<AsyncValue<UniversalLatLng?>> {
  final LocationService _locationService;

  CurrentLocationNotifier(this._locationService) : super(const AsyncValue.loading()) {
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      state = const AsyncValue.loading();
      final position = await _locationService.getCurrentPosition();
      state = AsyncValue.data(UniversalLatLng(position.latitude, position.longitude));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshLocation() async {
    await _loadCurrentLocation();
  }

  Future<UniversalLatLng?> getLastKnownLocation() async {
    try {
      final position = await _locationService.getLastKnownPosition();
      if (position != null) {
        return UniversalLatLng(position.latitude, position.longitude);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<UniversalLatLng> getLocationStream() {
    return _locationService.getPositionStream().map(
      (position) => UniversalLatLng(position.latitude, position.longitude),
    );
  }

  Future<double> calculateDistance(
    double startLat, double startLng,
    double endLat, double endLng,
  ) async {
    return await _locationService.calculateDistance(startLat, startLng, endLat, endLng);
  }

  bool isInKorea(UniversalLatLng location) {
    final locationServiceImpl = _locationService as LocationServiceImpl;
    return locationServiceImpl.isInKorea(location.latitude, location.longitude);
  }
}

class LocationPermissionNotifier extends StateNotifier<AsyncValue<PermissionStatus>> {
  final LocationService _locationService;

  LocationPermissionNotifier(this._locationService) : super(const AsyncValue.loading()) {
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    try {
      state = const AsyncValue.loading();
      final permission = await _locationService.checkPermission();
      state = AsyncValue.data(permission);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> requestPermission() async {
    try {
      state = const AsyncValue.loading();
      final permission = await _locationService.requestPermission();
      state = AsyncValue.data(permission);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshPermissionStatus() async {
    await _checkPermission();
  }

  bool get hasLocationPermission {
    return state.maybeWhen(
      data: (permission) => permission.isGranted,
      orElse: () => false,
    );
  }

  bool get isLocationPermissionDenied {
    return state.maybeWhen(
      data: (permission) => permission.isDenied,
      orElse: () => false,
    );
  }

  bool get isLocationPermissionPermanentlyDenied {
    return state.maybeWhen(
      data: (permission) => permission.isPermanentlyDenied,
      orElse: () => false,
    );
  }
}