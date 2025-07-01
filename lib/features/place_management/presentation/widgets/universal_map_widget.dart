import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locus_flutter/core/services/map/map_service.dart';
import 'package:locus_flutter/core/config/map_config.dart';
import 'package:locus_flutter/features/common/presentation/providers/location_provider.dart';
import 'package:locus_flutter/features/place_management/presentation/widgets/google_map_widget.dart';
import 'package:locus_flutter/features/place_management/presentation/widgets/naver_map_widget.dart';
import 'package:locus_flutter/features/place_management/domain/entities/place.dart' as app_place;
import 'package:locus_flutter/core/theme/app_theme.dart';

class UniversalMapWidget extends ConsumerStatefulWidget {
  final UniversalLatLng? initialLocation;
  final List<app_place.Place>? places;
  final Function(UniversalLatLng)? onLocationSelected;
  final Function(app_place.Place)? onPlaceSelected;
  final bool enableLocationSelection;
  final double zoom;
  final bool showMyLocationButton;
  final bool showMyLocation;
  final MapServiceType? preferredService;

  const UniversalMapWidget({
    super.key,
    this.initialLocation,
    this.places,
    this.onLocationSelected,
    this.onPlaceSelected,
    this.enableLocationSelection = false,
    this.zoom = 15.0,
    this.showMyLocationButton = true,
    this.showMyLocation = true,
    this.preferredService,
  });

  @override
  ConsumerState<UniversalMapWidget> createState() => _UniversalMapWidgetState();
}

class _UniversalMapWidgetState extends ConsumerState<UniversalMapWidget> {
  MapServiceType? _selectedService;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _determineMapService();
  }

  Future<void> _determineMapService() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      MapServiceType service;

      if (widget.preferredService != null) {
        // 사용자가 특정 서비스를 선호하는 경우
        service = widget.preferredService!;
      } else {
        // 위치 기반 자동 선택
        final currentLocation = ref.read(currentLocationProvider).value;
        if (currentLocation != null) {
          service = _selectServiceByLocation(currentLocation);
        } else {
          // 위치를 가져올 수 없는 경우 기본값 사용
          service = MapServiceType.google;
        }
      }

      if (mounted) {
        setState(() {
          _selectedService = service;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '지도 서비스 초기화 중 오류가 발생했습니다: $e';
          _selectedService = MapServiceType.google; // 기본값으로 폴백
          _isLoading = false;
        });
      }
    }
  }

  MapServiceType _selectServiceByLocation(UniversalLatLng location) {
    // 한국 지역 확인 (대략적인 범위)
    const double koreaMinLat = 33.0;
    const double koreaMaxLat = 38.9;
    const double koreaMinLng = 124.0;
    const double koreaMaxLng = 132.0;

    if (location.latitude >= koreaMinLat &&
        location.latitude <= koreaMaxLat &&
        location.longitude >= koreaMinLng &&
        location.longitude <= koreaMaxLng) {
      return MapServiceType.naver; // 한국 지역은 네이버 지도
    } else {
      return MapServiceType.google; // 해외 지역은 구글 지도
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    if (_selectedService == null) {
      return _buildErrorWidget('지도 서비스를 선택할 수 없습니다');
    }

    return Stack(
      children: [
        _buildMapWidget(),
        _buildServiceIndicator(),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
            ),
            SizedBox(height: 16),
            Text(
              '지도를 로딩하는 중...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget([String? customMessage]) {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                customMessage ?? _errorMessage ?? '지도를 로드할 수 없습니다',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _determineMapService,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                ),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapWidget() {
    switch (_selectedService!) {
      case MapServiceType.naver:
        return NaverMapWidget(
          initialLocation: widget.initialLocation,
          places: widget.places,
          onLocationSelected: widget.onLocationSelected,
          onPlaceSelected: widget.onPlaceSelected,
          enableLocationSelection: widget.enableLocationSelection,
          zoom: widget.zoom,
          showMyLocationButton: widget.showMyLocationButton,
          showMyLocation: widget.showMyLocation,
        );
      case MapServiceType.google:
        return GoogleMapWidget(
          initialLocation: widget.initialLocation,
          places: widget.places,
          onLocationSelected: widget.onLocationSelected,
          onPlaceSelected: widget.onPlaceSelected,
          enableLocationSelection: widget.enableLocationSelection,
          zoom: widget.zoom,
          showMyLocationButton: widget.showMyLocationButton,
          showMyLocation: widget.showMyLocation,
        );
    }
  }

  Widget _buildServiceIndicator() {
    return Positioned(
      top: 10,
      left: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _selectedService == MapServiceType.naver
                  ? Icons.map
                  : Icons.public,
              size: 16,
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(width: 4),
            Text(
              _selectedService == MapServiceType.naver ? 'Naver' : 'Google',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 외부에서 지도 서비스를 변경할 수 있는 메서드
  void changeMapService(MapServiceType newService) {
    if (_selectedService != newService) {
      setState(() {
        _selectedService = newService;
      });
    }
  }

  // 현재 사용 중인 지도 서비스 반환
  MapServiceType? get currentService => _selectedService;
}