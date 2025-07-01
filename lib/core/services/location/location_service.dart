import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class LocationService {
  Future<bool> isLocationServiceEnabled();
  Future<PermissionStatus> checkPermission();
  Future<PermissionStatus> requestPermission();
  Future<Position> getCurrentPosition();
  Future<Position?> getLastKnownPosition();
  Stream<Position> getPositionStream();
  Future<double> calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  );
}

class LocationServiceImpl implements LocationService {
  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10, // 10미터 이상 이동시에만 업데이트
  );

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<PermissionStatus> checkPermission() async {
    final permission = await Permission.location.status;
    return permission;
  }

  @override
  Future<PermissionStatus> requestPermission() async {
    // 먼저 현재 권한 상태 확인
    PermissionStatus permission = await Permission.location.status;
    
    if (permission.isDenied) {
      // 권한이 거부된 경우 요청
      permission = await Permission.location.request();
    }
    
    // 영구적으로 거부된 경우 설정 페이지로 이동 안내
    if (permission.isPermanentlyDenied) {
      // 여기서는 exception을 발생시키고 UI에서 처리하도록 함
      throw LocationPermissionPermanentlyDeniedException(
        'Location permission is permanently denied. Please enable it in settings.',
      );
    }
    
    return permission;
  }

  @override
  Future<Position> getCurrentPosition() async {
    // 위치 서비스 활성화 확인
    if (!await isLocationServiceEnabled()) {
      throw LocationServiceDisabledException(
        'Location services are disabled. Please enable location services.',
      );
    }
    
    // 권한 확인
    final permission = await checkPermission();
    if (permission.isDenied) {
      final requestedPermission = await requestPermission();
      if (requestedPermission.isDenied) {
        throw LocationPermissionDeniedException(
          'Location permission denied.',
        );
      }
    }
    
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      throw LocationException('Failed to get current location: $e');
    }
  }

  @override
  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      // 마지막 위치가 없거나 오류 발생시 null 반환
      return null;
    }
  }

  @override
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: _locationSettings,
    );
  }

  @override
  Future<double> calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) async {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // 현재 위치가 한국 내부인지 확인하는 유틸리티 메서드
  bool isInKorea(double latitude, double longitude) {
    // 한국의 대략적인 경계 (제주도 포함)
    const double koreaLatMin = 33.0;
    const double koreaLatMax = 38.9;
    const double koreaLngMin = 124.0;
    const double koreaLngMax = 132.0;
    
    return latitude >= koreaLatMin &&
           latitude <= koreaLatMax &&
           longitude >= koreaLngMin &&
           longitude <= koreaLngMax;
  }

  // 배터리 최적화를 위한 저전력 위치 설정
  static const LocationSettings _lowPowerLocationSettings = LocationSettings(
    accuracy: LocationAccuracy.low,
    distanceFilter: 100, // 100미터 이상 이동시에만 업데이트
  );

  Stream<Position> getLowPowerPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: _lowPowerLocationSettings,
    );
  }
}

// Location 관련 예외 클래스들
class LocationException implements Exception {
  final String message;
  LocationException(this.message);
  
  @override
  String toString() => 'LocationException: $message';
}

class LocationServiceDisabledException extends LocationException {
  LocationServiceDisabledException(super.message);
}

class LocationPermissionDeniedException extends LocationException {
  LocationPermissionDeniedException(super.message);
}

class LocationPermissionPermanentlyDeniedException extends LocationException {
  LocationPermissionPermanentlyDeniedException(super.message);
}