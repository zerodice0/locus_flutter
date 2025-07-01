import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart' as nmaps;
import 'package:locus_flutter/core/services/map/map_service.dart';
import 'package:locus_flutter/core/services/location/location_service.dart';
import 'package:locus_flutter/core/services/location/geocoding_service.dart';

class NaverMapService implements MapService {
  @override
  MapProvider get provider => MapProvider.naver;

  nmaps.NaverMapController? _controller;
  final LocationService _locationService;
  final GeocodingService _geocodingService;

  final Set<nmaps.NMarker> _markers = {};
  final Map<String, UniversalMarker> _universalMarkers = {};

  // Event callbacks
  Function(UniversalLatLng position)? _onMapTap;
  // Function(UniversalLatLng position)? _onMapLongPress; // Currently unused
  Function(String markerId)? _onMarkerTap;
  Function(UniversalCameraPosition position)? _onCameraMove;
  Function(UniversalCameraPosition position)? _onCameraIdle;

  NaverMapService({
    required LocationService locationService,
    required GeocodingService geocodingService,
  }) : _locationService = locationService,
       _geocodingService = geocodingService;

  @override
  Future<void> initialize() async {
    // Naver Maps SDK 초기화는 main.dart에서 처리됨
  }

  void setController(nmaps.NaverMapController controller) {
    _controller = controller;
  }

  @override
  Future<void> moveCamera(
    UniversalCameraPosition position, {
    bool animate = true,
  }) async {
    if (_controller == null) return;

    final cameraUpdate = nmaps.NCameraUpdate.withParams(
      target: nmaps.NLatLng(
        position.target.latitude,
        position.target.longitude,
      ),
      zoom: position.zoom,
      bearing: position.bearing,
      tilt: position.tilt,
    );

    if (animate) {
      await _controller!.updateCamera(
        cameraUpdate..setAnimation(
          animation: nmaps.NCameraAnimation.easing,
          duration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      await _controller!.updateCamera(cameraUpdate);
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

    final cameraPosition = await _controller!.getCameraPosition();
    return UniversalCameraPosition(
      target: UniversalLatLng(
        cameraPosition.target.latitude,
        cameraPosition.target.longitude,
      ),
      zoom: cameraPosition.zoom,
      bearing: cameraPosition.bearing,
      tilt: cameraPosition.tilt,
    );
  }

  @override
  Future<void> addMarker(UniversalMarker marker) async {
    _universalMarkers[marker.id] = marker;

    final nmarker = nmaps.NMarker(
      id: marker.id,
      position: nmaps.NLatLng(
        marker.position.latitude,
        marker.position.longitude,
      ),
    );

    // 마커 탭 이벤트 설정
    nmarker.setOnTapListener((nmaps.NMarker tappedMarker) {
      _onMarkerTap?.call(tappedMarker.info.id);
    });

    _markers.add(nmarker);

    // 컨트롤러가 있으면 즉시 추가
    if (_controller != null) {
      await _controller!.addOverlay(nmarker);
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

    final markerToRemove =
        _markers.where((marker) => marker.info.id == markerId).firstOrNull;
    if (markerToRemove != null) {
      _markers.remove(markerToRemove);
      if (_controller != null) {
        await _controller!.deleteOverlay(
          nmaps.NOverlayInfo(type: nmaps.NOverlayType.marker, id: markerId),
        );
      }
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

    if (_controller != null) {
      for (final marker in _markers) {
        await _controller!.deleteOverlay(
          nmaps.NOverlayInfo(
            type: nmaps.NOverlayType.marker,
            id: marker.info.id,
          ),
        );
      }
    }

    _markers.clear();
  }

  @override
  Future<void> updateMarker(UniversalMarker marker) async {
    await removeMarker(marker.id);
    await addMarker(marker);
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
    if (_controller == null) return;

    await _controller!.setLocationTrackingMode(
      show
          ? nmaps.NLocationTrackingMode.follow
          : nmaps.NLocationTrackingMode.none,
    );
  }

  @override
  Future<String?> getAddressFromCoordinates(UniversalLatLng position) async {
    return await _geocodingService.getAddressFromCoordinates(
      position.latitude,
      position.longitude,
    );
  }

  @override
  Future<List<UniversalLatLng>> getCoordinatesFromAddress(
    String address,
  ) async {
    final locations = await _geocodingService.getCoordinatesFromAddress(
      address,
    );
    return locations
        .map(
          (location) => UniversalLatLng(location.latitude, location.longitude),
        )
        .toList();
  }

  @override
  Future<void> setMapTheme(MapTheme theme) async {
    // Naver Maps 맵 타입 설정은 위젯 레벨에서 처리됨
  }

  @override
  Future<void> setMapStyle(String? styleJson) async {
    // Naver Maps는 커스텀 스타일을 지원하지 않음
    // 대신 미리 정의된 맵 타입을 사용
  }

  @override
  void setOnMapTap(Function(UniversalLatLng position)? callback) {
    _onMapTap = callback;
  }

  @override
  void setOnMapLongPress(Function(UniversalLatLng position)? callback) {
    // _onMapLongPress = callback; // Currently unused
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
  Future<void> fitBounds(
    List<UniversalLatLng> positions, {
    double padding = 50,
  }) async {
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

    final bounds = nmaps.NLatLngBounds(
      southWest: nmaps.NLatLng(minLat, minLng),
      northEast: nmaps.NLatLng(maxLat, maxLng),
    );

    final cameraUpdate = nmaps.NCameraUpdate.fitBounds(bounds);
    await _controller!.updateCamera(cameraUpdate);
  }

  @override
  double calculateDistance(UniversalLatLng start, UniversalLatLng end) {
    return start.distanceTo(end);
  }

  @override
  Future<UniversalLatLng?> screenToLatLng(Offset screenPoint) async {
    if (_controller == null) return null;

    final latLng = await _controller!.screenLocationToLatLng(
      nmaps.NPoint(screenPoint.dx, screenPoint.dy),
    );

    return UniversalLatLng(latLng.latitude, latLng.longitude);
  }

  @override
  Future<Offset?> latLngToScreen(UniversalLatLng position) async {
    if (_controller == null) return null;

    final screenPoint = await _controller!.latLngToScreenLocation(
      nmaps.NLatLng(position.latitude, position.longitude),
    );

    return Offset(screenPoint.x, screenPoint.y);
  }

  @override
  void dispose() {
    _controller = null;
    _markers.clear();
    _universalMarkers.clear();
    _onMapTap = null;
    // _onMapLongPress = null; // Currently unused
    _onMarkerTap = null;
    _onCameraMove = null;
    _onCameraIdle = null;
  }

  // Naver Maps 위젯용 콜백들
  void onMapReady(nmaps.NaverMapController controller) {
    setController(controller);
  }

  void onMapTapped(nmaps.NPoint point, nmaps.NLatLng latLng) {
    _onMapTap?.call(UniversalLatLng(latLng.latitude, latLng.longitude));
  }

  void onSymbolTapped(nmaps.NSymbolInfo symbolInfo) {
    // 심볼 탭 처리
  }

  void onCameraChange(nmaps.NCameraUpdateReason reason, bool animated) {
    getCameraPosition().then((position) {
      _onCameraMove?.call(position);
    });
  }

  void onCameraIdle() {
    getCameraPosition().then((position) {
      _onCameraIdle?.call(position);
    });
  }

  void onSelectedIndoorChanged(nmaps.NSelectedIndoor? selectedIndoor) {
    // 실내 지도 변경 처리
  }
}
