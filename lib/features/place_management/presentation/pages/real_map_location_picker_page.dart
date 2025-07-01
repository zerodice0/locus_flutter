import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:locus_flutter/features/common/presentation/widgets/custom_app_bar.dart';
import 'package:locus_flutter/features/common/presentation/providers/location_provider.dart';
import 'package:locus_flutter/features/place_management/presentation/widgets/universal_map_widget.dart';
import 'package:locus_flutter/core/theme/app_theme.dart';
import 'package:locus_flutter/core/services/map/map_service.dart';
import 'package:locus_flutter/core/services/location/geocoding_service.dart';
import 'package:locus_flutter/core/config/map_config.dart';

class RealMapLocationPickerPage extends ConsumerStatefulWidget {
  final UniversalLatLng? initialLocation;
  final MapServiceType? preferredService;
  
  const RealMapLocationPickerPage({
    super.key,
    this.initialLocation,
    this.preferredService,
  });

  @override
  ConsumerState<RealMapLocationPickerPage> createState() => _RealMapLocationPickerPageState();
}

class _RealMapLocationPickerPageState extends ConsumerState<RealMapLocationPickerPage> {
  UniversalLatLng? _selectedLocation;
  String? _selectedAddress;
  bool _isLoadingAddress = false;
  String? _addressError;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    if (_selectedLocation != null) {
      _loadAddress(_selectedLocation!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocationAsync = ref.watch(currentLocationProvider);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: '위치 선택',
        actions: [
          if (_selectedLocation != null)
            TextButton(
              onPressed: _confirmSelection,
              child: const Text(
                '선택',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // 지도 컨테이너
          Expanded(
            child: UniversalMapWidget(
              initialLocation: widget.initialLocation ?? 
                  currentLocationAsync.value ??
                  const UniversalLatLng(37.5665, 126.9780), // 서울 기본 위치
              enableLocationSelection: true,
              onLocationSelected: _onLocationSelected,
              preferredService: widget.preferredService,
              showMyLocationButton: true,
              showMyLocation: true,
              zoom: 15.0,
            ),
          ),
          
          // 선택된 위치 정보 패널
          if (_selectedLocation != null)
            _buildLocationInfoPanel(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _goToCurrentLocation(currentLocationAsync.value),
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.my_location),
        label: const Text('현재 위치'),
      ),
    );
  }

  Widget _buildLocationInfoPanel() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppTheme.primaryGreen,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '선택된 위치',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _clearSelection,
                icon: const Icon(Icons.close),
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 좌표 정보
          _buildCoordinateInfo(),
          
          // 주소 정보
          if (_selectedAddress != null || _isLoadingAddress || _addressError != null) ...[
            const SizedBox(height: 12),
            _buildAddressInfo(),
          ],
          
          const SizedBox(height: 16),
          
          // 액션 버튼들
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearSelection,
                  child: const Text('다시 선택'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _confirmSelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                  child: const Text('이 위치 사용'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinateInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '위도: ${_selectedLocation!.latitude.toStringAsFixed(6)}',
                  style: AppTheme.bodySmall.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  '경도: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                  style: AppTheme.bodySmall.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _copyCoordinates,
            icon: const Icon(Icons.copy),
            iconSize: 20,
            tooltip: '좌표 복사',
          ),
        ],
      ),
    );
  }

  Widget _buildAddressInfo() {
    if (_isLoadingAddress) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '주소를 가져오는 중...',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.primaryGreen,
              ),
            ),
          ],
        ),
      );
    }

    if (_addressError != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber,
              color: Colors.orange,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _addressError!,
                style: AppTheme.bodySmall.copyWith(
                  color: Colors.orange.shade700,
                ),
              ),
            ),
            IconButton(
              onPressed: () => _loadAddress(_selectedLocation!),
              icon: const Icon(Icons.refresh),
              iconSize: 16,
              tooltip: '다시 시도',
            ),
          ],
        ),
      );
    }

    if (_selectedAddress != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.place,
              color: AppTheme.primaryGreen,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedAddress!,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _onLocationSelected(UniversalLatLng location) {
    setState(() {
      _selectedLocation = location;
      _selectedAddress = null;
      _addressError = null;
    });
    
    _loadAddress(location);
  }

  void _goToCurrentLocation(UniversalLatLng? currentLocation) {
    if (currentLocation != null) {
      _onLocationSelected(currentLocation);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('현재 위치를 가져올 수 없습니다'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  Future<void> _loadAddress(UniversalLatLng location) async {
    setState(() {
      _isLoadingAddress = true;
      _addressError = null;
    });
    
    try {
      final geocodingService = ref.read(geocodingServiceProvider);
      final address = await geocodingService.getAddressFromCoordinates(
        location.latitude,
        location.longitude,
      );
      
      if (mounted) {
        setState(() {
          _selectedAddress = address ?? '주소를 찾을 수 없습니다';
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _addressError = '주소를 가져오는 중 오류가 발생했습니다';
          _isLoadingAddress = false;
        });
      }
    }
  }

  void _copyCoordinates() {
    // TODO: 클립보드에 복사 기능 구현
    if (_selectedLocation != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('좌표가 클립보드에 복사되었습니다'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedLocation = null;
      _selectedAddress = null;
      _addressError = null;
      _isLoadingAddress = false;
    });
  }

  void _confirmSelection() {
    if (_selectedLocation != null) {
      context.pop(_selectedLocation);
    }
  }
}