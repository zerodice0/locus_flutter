import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:locus_flutter/core/services/map/map_service.dart';
import 'package:locus_flutter/core/services/location/location_service.dart';
import 'package:locus_flutter/core/services/location/geocoding_service.dart';

class GoogleMapService implements MapService {
  @override
  MapProvider get provider => MapProvider.google;
  
  gmaps.GoogleMapController? _controller;
  final LocationService _locationService;
  final GeocodingService _geocodingService;
  
  final Set<gmaps.Marker> _markers = {};
  final Map<String, UniversalMarker> _universalMarkers = {};
  
  // Event callbacks
  Function(UniversalLatLng position)? _onMapTap;
  Function(UniversalLatLng position)? _onMapLongPress;
  Function(String markerId)? _onMarkerTap;
  Function(UniversalCameraPosition position)? _onCameraMove;
  Function(UniversalCameraPosition position)? _onCameraIdle;
  
  GoogleMapService({
    required LocationService locationService,
    required GeocodingService geocodingService,
  }) : _locationService = locationService,
       _geocodingService = geocodingService;

  @override
  Future<void> initialize() async {
    // Google Maps는 별도 초기화가 필요하지 않음
    // API 키는 android/app/src/main/AndroidManifest.xml 및 ios/Runner/AppDelegate.swift에서 설정
  }

  void setController(gmaps.GoogleMapController controller) {
    _controller = controller;
  }

  @override
  Future<void> moveCamera(UniversalCameraPosition position, {bool animate = true}) async {
    if (_controller == null) return;
    
    final cameraPosition = gmaps.CameraPosition(
      target: gmaps.LatLng(position.target.latitude, position.target.longitude),
      zoom: position.zoom,
      bearing: position.bearing,
      tilt: position.tilt,
    );
    
    if (animate) {
      await _controller!.animateCamera(gmaps.CameraUpdate.newCameraPosition(cameraPosition));
    } else {
      await _controller!.moveCamera(gmaps.CameraUpdate.newCameraPosition(cameraPosition));
    }
  }

  @override
  Future<void> animateCamera(UniversalCameraPosition position) async {
    return moveCamera(position, animate: true);
  }

  @override
  Future<UniversalCameraPosition> getCameraPosition() async {
    if (_controller == null) {
      throw MapServiceException('Map controller not initialized');
    }
    
    final cameraPosition = await _controller!.getVisibleRegion();
    final center = UniversalLatLng(
      (cameraPosition.northeast.latitude + cameraPosition.southwest.latitude) / 2,
      (cameraPosition.northeast.longitude + cameraPosition.southwest.longitude) / 2,
    );
    
    return UniversalCameraPosition(target: center);
  }

  @override
  Future<void> addMarker(UniversalMarker marker) async {
    _universalMarkers[marker.id] = marker;
    
    final gmapsMarker = gmaps.Marker(
      markerId: gmaps.MarkerId(marker.id),
      position: gmaps.LatLng(marker.position.latitude, marker.position.longitude),
      infoWindow: gmaps.InfoWindow(
        title: marker.title,
        snippet: marker.snippet,
      ),
      onTap: () => _onMarkerTap?.call(marker.id),
    );
    
    _markers.add(gmapsMarker);
    
    // 컨트롤러가 있으면 즉시 업데이트
    if (_controller != null) {
      await _updateMarkers();
    }
  }

  @override
  Future<void> addMarkers(List<UniversalMarker> markers) async {
    for (final marker in markers) {
      await addMarker(marker);
    }
  }

  @override
  Future<void> removeMarker(String markerId) async {
    _universalMarkers.remove(markerId);
    _markers.removeWhere((marker) => marker.markerId.value == markerId);
    
    if (_controller != null) {
      await _updateMarkers();
    }
  }

  @override
  Future<void> removeMarkers(List<String> markerIds) async {
    for (final markerId in markerIds) {
      await removeMarker(markerId);
    }
  }

  @override
  Future<void> clearMarkers() async {
    _universalMarkers.clear();
    _markers.clear();
    
    if (_controller != null) {
      await _updateMarkers();
    }
  }

  @override
  Future<void> updateMarker(UniversalMarker marker) async {
    await removeMarker(marker.id);
    await addMarker(marker);
  }

  Future<void> _updateMarkers() async {
    // Google Maps는 마커 업데이트를 위해 새로운 상태를 설정해야 함
    // 이는 일반적으로 StatefulWidget에서 setState를 통해 처리됨
  }

  @override
  Future<UniversalLatLng?> getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      return UniversalLatLng(position.latitude, position.longitude);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> showUserLocation(bool show) async {
    // Google Maps의 myLocationEnabled은 위젯 레벨에서 설정됨
  }

  @override
  Future<String?> getAddressFromCoordinates(UniversalLatLng position) async {
    return await _geocodingService.getAddressFromCoordinates(
      position.latitude, 
      position.longitude,
    );
  }

  @override
  Future<List<UniversalLatLng>> getCoordinatesFromAddress(String address) async {
    final locations = await _geocodingService.getCoordinatesFromAddress(address);
    return locations.map((location) => 
        UniversalLatLng(location.latitude, location.longitude)).toList();
  }

  @override
  Future<void> setMapTheme(MapTheme theme) async {
    // Google Maps 테마는 위젯 레벨에서 설정됨
  }

  @override
  Future<void> setMapStyle(String? styleJson) async {
    // Google Maps 스타일은 위젯 레벨에서 설정됨
    // 이 메서드는 향후 호환성을 위해 유지
  }

  @override
  void setOnMapTap(Function(UniversalLatLng position)? callback) {
    _onMapTap = callback;
  }

  @override
  void setOnMapLongPress(Function(UniversalLatLng position)? callback) {
    _onMapLongPress = callback;
  }

  @override
  void setOnMarkerTap(Function(String markerId)? callback) {
    _onMarkerTap = callback;
  }

  @override
  void setOnCameraMove(Function(UniversalCameraPosition position)? callback) {
    _onCameraMove = callback;
  }

  @override
  void setOnCameraIdle(Function(UniversalCameraPosition position)? callback) {
    _onCameraIdle = callback;
  }

  @override
  Future<void> fitBounds(List<UniversalLatLng> positions, {double padding = 50}) async {
    if (_controller == null || positions.isEmpty) return;
    
    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;
    
    for (final position in positions) {
      minLat = minLat < position.latitude ? minLat : position.latitude;
      maxLat = maxLat > position.latitude ? maxLat : position.latitude;
      minLng = minLng < position.longitude ? minLng : position.longitude;
      maxLng = maxLng > position.longitude ? maxLng : position.longitude;
    }
    
    await _controller!.animateCamera(
      gmaps.CameraUpdate.newLatLngBounds(
        gmaps.LatLngBounds(
          southwest: gmaps.LatLng(minLat, minLng),
          northeast: gmaps.LatLng(maxLat, maxLng),
        ),
        padding,
      ),
    );
  }

  @override
  double calculateDistance(UniversalLatLng start, UniversalLatLng end) {
    return start.distanceTo(end);
  }

  @override
  Future<UniversalLatLng?> screenToLatLng(Offset screenPoint) async {
    if (_controller == null) return null;
    
    final screenCoordinate = gmaps.ScreenCoordinate(
      x: screenPoint.dx.round(),
      y: screenPoint.dy.round(),
    );
    final latLng = await _controller!.getLatLng(screenCoordinate);
    return UniversalLatLng(latLng.latitude, latLng.longitude);
  }

  @override
  Future<Offset?> latLngToScreen(UniversalLatLng position) async {
    if (_controller == null) return null;
    
    final screenCoordinate = await _controller!.getScreenCoordinate(
      gmaps.LatLng(position.latitude, position.longitude),
    );
    return Offset(screenCoordinate.x.toDouble(), screenCoordinate.y.toDouble());
  }

  @override
  void dispose() {
    _controller = null;
    _markers.clear();
    _universalMarkers.clear();
    _onMapTap = null;
    _onMapLongPress = null;
    _onMarkerTap = null;
    _onCameraMove = null;
    _onCameraIdle = null;
  }

  // Google Maps 위젯용 콜백들
  void onMapCreated(gmaps.GoogleMapController controller) {
    setController(controller);
  }

  void onTap(gmaps.LatLng position) {
    _onMapTap?.call(UniversalLatLng(position.latitude, position.longitude));
  }

  void onLongPress(gmaps.LatLng position) {
    _onMapLongPress?.call(UniversalLatLng(position.latitude, position.longitude));
  }

  void onCameraMove(gmaps.CameraPosition position) {
    _onCameraMove?.call(UniversalCameraPosition(
      target: UniversalLatLng(position.target.latitude, position.target.longitude),
      zoom: position.zoom,
      bearing: position.bearing,
      tilt: position.tilt,
    ));
  }

  void onCameraIdle() {
    // 카메라 위치를 가져와서 콜백 호출
    getCameraPosition().then((position) {
      _onCameraIdle?.call(position);
    });
  }

  // 마커 집합 반환 (Google Maps 위젯에서 사용)
  Set<gmaps.Marker> get markers => _markers;
}