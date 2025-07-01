import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:locus_flutter/core/services/map/map_service.dart';
import 'package:locus_flutter/core/config/map_config.dart';
import 'package:locus_flutter/core/theme/app_theme.dart';
import 'package:locus_flutter/features/place_management/domain/entities/place.dart' as app_place;

class GoogleMapWidget extends StatefulWidget {
  final UniversalLatLng? initialLocation;
  final List<app_place.Place>? places;
  final Function(UniversalLatLng)? onLocationSelected;
  final Function(app_place.Place)? onPlaceSelected;
  final bool enableLocationSelection;
  final double zoom;
  final bool showMyLocationButton;
  final bool showMyLocation;

  const GoogleMapWidget({
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
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  LatLng? _selectedLocation;

  // 기본 서울 위치
  static const LatLng _defaultLocation = LatLng(37.5665, 126.9780);

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
  }

  @override
  void didUpdateWidget(GoogleMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.places != widget.places) {
      _initializeMarkers();
    }
  }

  void _initializeMarkers() {
    _markers.clear();
    
    if (widget.places != null) {
      for (final place in widget.places!) {
        _markers.add(
          Marker(
            markerId: MarkerId(place.id),
            position: LatLng(place.latitude, place.longitude),
            infoWindow: InfoWindow(
              title: place.name,
              snippet: place.address ?? '주소 정보 없음',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              _getMarkerColorForCategory(place.categoryId),
            ),
            onTap: () {
              widget.onPlaceSelected?.call(place);
            },
          ),
        );
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  double _getMarkerColorForCategory(String? categoryId) {
    // 카테고리별 마커 색상 (HSV Hue 값)
    switch (categoryId) {
      case 'restaurant':
        return BitmapDescriptor.hueRed;
      case 'cafe':
        return BitmapDescriptor.hueOrange;
      case 'shopping':
        return BitmapDescriptor.hueBlue;
      case 'entertainment':
        return BitmapDescriptor.hueMagenta;
      case 'hospital':
        return BitmapDescriptor.hueGreen;
      case 'education':
        return BitmapDescriptor.hueCyan;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  LatLng get _initialCameraPosition {
    if (widget.initialLocation != null) {
      return LatLng(
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
        GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
            _applyMapStyle();
          },
          initialCameraPosition: CameraPosition(
            target: _initialCameraPosition,
            zoom: widget.zoom,
          ),
          markers: _markers,
          onTap: widget.enableLocationSelection ? _onMapTapped : null,
          myLocationEnabled: widget.showMyLocation,
          myLocationButtonEnabled: widget.showMyLocationButton,
          zoomControlsEnabled: true,
          mapToolbarEnabled: false,
          compassEnabled: true,
          rotateGesturesEnabled: true,
          scrollGesturesEnabled: true,
          tiltGesturesEnabled: true,
          zoomGesturesEnabled: true,
          mapType: MapType.normal,
          buildingsEnabled: true,
          trafficEnabled: false,
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

  void _onMapTapped(LatLng position) {
    if (!widget.enableLocationSelection) return;

    setState(() {
      _selectedLocation = position;
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: const InfoWindow(
            title: '선택된 위치',
          ),
        ),
      );
    });
  }

  void _clearSelectedLocation() {
    setState(() {
      _selectedLocation = null;
      _markers.removeWhere(
        (marker) => marker.markerId.value == 'selected_location',
      );
    });
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
      await _controller!.animateCamera(CameraUpdate.zoomIn());
    }
  }

  Future<void> _zoomOut() async {
    if (_controller != null) {
      await _controller!.animateCamera(CameraUpdate.zoomOut());
    }
  }

  Future<void> _resetCamera() async {
    if (_controller != null) {
      await _controller!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _initialCameraPosition,
            zoom: widget.zoom,
          ),
        ),
      );
    }
  }

  Future<void> _applyMapStyle() async {
    if (_controller == null) return;

    const String mapStyle = '''
    [
      {
        "featureType": "poi",
        "elementType": "labels",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "featureType": "transit",
        "elementType": "labels",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      }
    ]
    ''';

    try {
      await _controller!.setMapStyle(mapStyle);
    } catch (e) {
      debugPrint('Failed to apply map style: $e');
    }
  }

  // 특정 위치로 카메라 이동
  Future<void> moveCamera(UniversalLatLng location, {double? zoom}) async {
    if (_controller != null) {
      await _controller!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(location.latitude, location.longitude),
            zoom: zoom ?? widget.zoom,
          ),
        ),
      );
    }
  }

  // 마커 추가
  void addMarker(app_place.Place place) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(place.id),
          position: LatLng(place.latitude, place.longitude),
          infoWindow: InfoWindow(
            title: place.name,
            snippet: place.address,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getMarkerColorForCategory(place.categoryId),
          ),
          onTap: () {
            widget.onPlaceSelected?.call(place);
          },
        ),
      );
    });
  }

  // 마커 제거
  void removeMarker(String placeId) {
    setState(() {
      _markers.removeWhere(
        (marker) => marker.markerId.value == placeId,
      );
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}