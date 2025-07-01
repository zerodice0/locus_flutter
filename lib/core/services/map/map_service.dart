import 'dart:math' as math;
import 'package:flutter/material.dart';

// 통합 좌표 시스템
class UniversalLatLng {
  final double latitude;
  final double longitude;
  
  const UniversalLatLng(this.latitude, this.longitude);
  
  @override
  String toString() => 'UniversalLatLng($latitude, $longitude)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UniversalLatLng &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;
  
  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
  
  // 거리 계산 (Haversine formula)
  double distanceTo(UniversalLatLng other) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double dLat = _degreesToRadians(other.latitude - latitude);
    final double dLng = _degreesToRadians(other.longitude - longitude);
    
    final double a = 
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(latitude)) * math.cos(_degreesToRadians(other.latitude)) *
        math.sin(dLng / 2) * math.sin(dLng / 2);
    
    final double c = 2 * math.asin(math.sqrt(a));
    
    return earthRadius * c;
  }
  
  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}

// 지도 마커 정보
class UniversalMarker {
  final String id;
  final UniversalLatLng position;
  final String? title;
  final String? snippet;
  final String? iconAsset;
  final Color? color;
  final VoidCallback? onTap;
  final Map<String, dynamic>? metadata;
  
  const UniversalMarker({
    required this.id,
    required this.position,
    this.title,
    this.snippet,
    this.iconAsset,
    this.color,
    this.onTap,
    this.metadata,
  });
  
  UniversalMarker copyWith({
    String? id,
    UniversalLatLng? position,
    String? title,
    String? snippet,
    String? iconAsset,
    Color? color,
    VoidCallback? onTap,
    Map<String, dynamic>? metadata,
  }) {
    return UniversalMarker(
      id: id ?? this.id,
      position: position ?? this.position,
      title: title ?? this.title,
      snippet: snippet ?? this.snippet,
      iconAsset: iconAsset ?? this.iconAsset,
      color: color ?? this.color,
      onTap: onTap ?? this.onTap,
      metadata: metadata ?? this.metadata,
    );
  }
}

// 지도 카메라 위치
class UniversalCameraPosition {
  final UniversalLatLng target;
  final double zoom;
  final double bearing;
  final double tilt;
  
  const UniversalCameraPosition({
    required this.target,
    this.zoom = 15.0,
    this.bearing = 0.0,
    this.tilt = 0.0,
  });
  
  UniversalCameraPosition copyWith({
    UniversalLatLng? target,
    double? zoom,
    double? bearing,
    double? tilt,
  }) {
    return UniversalCameraPosition(
      target: target ?? this.target,
      zoom: zoom ?? this.zoom,
      bearing: bearing ?? this.bearing,
      tilt: tilt ?? this.tilt,
    );
  }
}

// 지도 제공자 열거형
enum MapProvider { 
  naver, 
  google,
  auto  // 위치 기반 자동 선택
}

// 지도 테마
enum MapTheme {
  light,
  dark,
  satellite,
  terrain
}

// 지도 서비스 추상화 인터페이스
abstract class MapService {
  MapProvider get provider;
  
  // 지도 초기화
  Future<void> initialize();
  
  // 카메라 조작
  Future<void> moveCamera(UniversalCameraPosition position, {bool animate = true});
  Future<void> animateCamera(UniversalCameraPosition position);
  Future<UniversalCameraPosition> getCameraPosition();
  
  // 마커 관리
  Future<void> addMarker(UniversalMarker marker);
  Future<void> addMarkers(List<UniversalMarker> markers);
  Future<void> removeMarker(String markerId);
  Future<void> removeMarkers(List<String> markerIds);
  Future<void> clearMarkers();
  Future<void> updateMarker(UniversalMarker marker);
  
  // 위치 관련
  Future<UniversalLatLng?> getCurrentLocation();
  Future<void> showUserLocation(bool show);
  
  // 주소 변환
  Future<String?> getAddressFromCoordinates(UniversalLatLng position);
  Future<List<UniversalLatLng>> getCoordinatesFromAddress(String address);
  
  // 지도 스타일
  Future<void> setMapTheme(MapTheme theme);
  Future<void> setMapStyle(String? styleJson);
  
  // 이벤트 리스너
  void setOnMapTap(Function(UniversalLatLng position)? callback);
  void setOnMapLongPress(Function(UniversalLatLng position)? callback);
  void setOnMarkerTap(Function(String markerId)? callback);
  void setOnCameraMove(Function(UniversalCameraPosition position)? callback);
  void setOnCameraIdle(Function(UniversalCameraPosition position)? callback);
  
  // 지도 경계 설정
  Future<void> fitBounds(List<UniversalLatLng> positions, {double padding = 50});
  
  // 거리 계산
  double calculateDistance(UniversalLatLng start, UniversalLatLng end);
  
  // 화면 좌표 변환
  Future<UniversalLatLng?> screenToLatLng(Offset screenPoint);
  Future<Offset?> latLngToScreen(UniversalLatLng position);
  
  // 리소스 정리
  void dispose();
}

// 지도 서비스 예외
class MapServiceException implements Exception {
  final String message;
  final MapProvider? provider;
  
  const MapServiceException(this.message, {this.provider});
  
  @override
  String toString() => 'MapServiceException: $message';
}

class MapInitializationException extends MapServiceException {
  const MapInitializationException(super.message, {super.provider});
}

class MapPermissionException extends MapServiceException {
  const MapPermissionException(super.message, {super.provider});
}

class MapNetworkException extends MapServiceException {
  const MapNetworkException(super.message, {super.provider});
}