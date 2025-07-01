import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:locus_flutter/core/services/map/map_service.dart';
import 'package:locus_flutter/core/config/map_config.dart';
import 'package:locus_flutter/core/theme/app_theme.dart';
import 'package:locus_flutter/features/place_management/domain/entities/place.dart' as app_place;

class NaverMapWidget extends StatefulWidget {
  final UniversalLatLng? initialLocation;
  final List<app_place.Place>? places;
  final Function(UniversalLatLng)? onLocationSelected;
  final Function(app_place.Place)? onPlaceSelected;
  final bool enableLocationSelection;
  final double zoom;
  final bool showMyLocationButton;
  final bool showMyLocation;

  const NaverMapWidget({
    super.key,
    this.initialLocation,
    this.places,
    this.onLocationSelected,
    this.onPlaceSelected,
    this.enableLocationSelection = false,
    this.zoom = 15.0,
    this.showMyLocationButton = true,
    this.showMyLocation = true,
  });

  @override
  State<NaverMapWidget> createState() => _NaverMapWidgetState();
}

class _NaverMapWidgetState extends State<NaverMapWidget> {
  NaverMapController? _controller;
  Set<NMarker> _markers = {};
  NLatLng? _selectedLocation;

  // 기본 서울 위치
  static const NLatLng _defaultLocation = NLatLng(37.5665, 126.9780);

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
  }

  @override
  void didUpdateWidget(NaverMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.places != widget.places) {
      _initializeMarkers();
    }
  }

  void _initializeMarkers() {
    _markers.clear();
    
    if (widget.places != null) {
      for (final place in widget.places!) {
        final marker = NMarker(
          id: place.id,
          position: NLatLng(place.latitude, place.longitude),
          caption: NOverlayCaption(
            text: place.name,
          ),
          iconTintColor: _getMarkerColorForCategory(place.categoryId),
        );
        
        marker.setOnTapListener((NMarker marker) {
          final selectedPlace = widget.places!.firstWhere(
            (p) => p.id == marker.info.id,
          );
          widget.onPlaceSelected?.call(selectedPlace);
        });
        
        _markers.add(marker);
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Color _getMarkerColorForCategory(String? categoryId) {
    // 카테고리별 마커 색상
    switch (categoryId) {
      case 'restaurant':
        return Colors.red;
      case 'cafe':
        return Colors.orange;
      case 'shopping':
        return Colors.blue;
      case 'entertainment':
        return Colors.purple;
      case 'hospital':
        return Colors.green;
      case 'education':
        return Colors.cyan;
      default:
        return AppTheme.primaryGreen;
    }
  }

  NLatLng get _initialCameraPosition {
    if (widget.initialLocation != null) {
      return NLatLng(
        widget.initialLocation!.latitude,
        widget.initialLocation!.longitude,
      );
    }
    return _defaultLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NaverMap(
          options: NaverMapViewOptions(
            initialCameraPosition: NCameraPosition(
              target: _initialCameraPosition,
              zoom: widget.zoom,
            ),
            mapType: NMapType.basic,
            activeLayerGroups: [NLayerGroup.building, NLayerGroup.transit],
            rotationGesturesEnable: true,
            scrollGesturesEnable: true,
            tiltGesturesEnable: true,
            zoomGesturesEnable: true,
            locationButtonEnable: widget.showMyLocationButton,
            consumeSymbolTapEvents: false,
          ),
          onMapReady: (NaverMapController controller) {
            _controller = controller;
            _addMarkersToMap();
          },
          onMapTapped: (NPoint point, NLatLng latLng) {
            if (widget.enableLocationSelection) {
              _onMapTapped(latLng);
            }
          },
          onCameraChange: (NCameraUpdateReason reason, bool animated) {
            // 카메라 변경 시 처리할 로직이 있다면 여기에
          },
        ),
        
        // 위치 선택 모드일 때 선택된 위치 표시
        if (widget.enableLocationSelection && _selectedLocation != null)
          _buildSelectedLocationOverlay(),
          
        // 지도 컨트롤 오버레이
        _buildMapControls(),
      ],
    );
  }

  Widget _buildSelectedLocationOverlay() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(width: 8),
                const Text(
                  '선택된 위치',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _clearSelectedLocation,
                  icon: const Icon(Icons.close),
                  iconSize: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '위도: ${_selectedLocation!.latitude.toStringAsFixed(6)}\n'
              '경도: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _confirmLocationSelection,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
              ),
              child: const Text('이 위치 선택'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      top: 20,
      right: 20,
      child: Column(
        children: [
          FloatingActionButton.small(
            onPressed: _zoomIn,
            backgroundColor: Colors.white,
            child: const Icon(Icons.zoom_in),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            onPressed: _zoomOut,
            backgroundColor: Colors.white,
            child: const Icon(Icons.zoom_out),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            onPressed: _resetCamera,
            backgroundColor: Colors.white,
            child: const Icon(Icons.center_focus_strong),
          ),
        ],
      ),
    );
  }

  Future<void> _addMarkersToMap() async {
    if (_controller != null && _markers.isNotEmpty) {
      await _controller!.addOverlayAll(_markers.toSet());
    }
  }

  void _onMapTapped(NLatLng position) {
    if (!widget.enableLocationSelection) return;

    setState(() {
      _selectedLocation = position;
    });

    // 선택된 위치에 마커 추가
    _addSelectionMarker(position);
  }

  void _addSelectionMarker(NLatLng position) async {
    if (_controller == null) return;

    // 기존 선택 마커 제거
    await _clearSelectionMarker();

    // 새 선택 마커 추가
    final selectionMarker = NMarker(
      id: 'selected_location',
      position: position,
      caption: NOverlayCaption(
        text: '선택된 위치',
      ),
      iconTintColor: AppTheme.primaryGreen,
    );

    await _controller!.addOverlay(selectionMarker);
  }

  Future<void> _clearSelectionMarker() async {
    if (_controller != null) {
      try {
        await _controller!.deleteOverlay(const NOverlayInfo(type: NOverlayType.marker, id: 'selected_location'));
      } catch (e) {
        // 마커가 존재하지 않는 경우 무시
      }
    }
  }

  void _clearSelectedLocation() {
    setState(() {
      _selectedLocation = null;
    });
    _clearSelectionMarker();
  }

  void _confirmLocationSelection() {
    if (_selectedLocation != null) {
      final universalLocation = UniversalLatLng(
        _selectedLocation!.latitude,
        _selectedLocation!.longitude,
      );
      widget.onLocationSelected?.call(universalLocation);
    }
  }

  Future<void> _zoomIn() async {
    if (_controller != null) {
      final currentZoom = await _controller!.getCameraPosition();
      await _controller!.updateCamera(
        NCameraUpdate.withParams(
          zoom: currentZoom.zoom + 1,
        ),
      );
    }
  }

  Future<void> _zoomOut() async {
    if (_controller != null) {
      final currentZoom = await _controller!.getCameraPosition();
      await _controller!.updateCamera(
        NCameraUpdate.withParams(
          zoom: currentZoom.zoom - 1,
        ),
      );
    }
  }

  Future<void> _resetCamera() async {
    if (_controller != null) {
      await _controller!.updateCamera(
        NCameraUpdate.withParams(
          target: _initialCameraPosition,
          zoom: widget.zoom,
        ),
      );
    }
  }

  // 특정 위치로 카메라 이동
  Future<void> moveCamera(UniversalLatLng location, {double? zoom}) async {
    if (_controller != null) {
      await _controller!.updateCamera(
        NCameraUpdate.withParams(
          target: NLatLng(location.latitude, location.longitude),
          zoom: zoom ?? widget.zoom,
        ),
      );
    }
  }

  // 마커 추가
  Future<void> addMarker(app_place.Place place) async {
    if (_controller == null) return;

    final marker = NMarker(
      id: place.id,
      position: NLatLng(place.latitude, place.longitude),
      caption: NOverlayCaption(
        text: place.name,
      ),
      iconTintColor: _getMarkerColorForCategory(place.categoryId),
    );
    
    marker.setOnTapListener((NMarker marker) {
      widget.onPlaceSelected?.call(place);
    });

    await _controller!.addOverlay(marker);
    
    setState(() {
      _markers.add(marker);
    });
  }

  // 마커 제거
  Future<void> removeMarker(String placeId) async {
    if (_controller == null) return;

    try {
      await _controller!.deleteOverlay(NOverlayInfo(type: NOverlayType.marker, id: placeId));
      setState(() {
        _markers.removeWhere((marker) => marker.info.id == placeId);
      });
    } catch (e) {
      debugPrint('Failed to remove marker: $e');
    }
  }

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }
}