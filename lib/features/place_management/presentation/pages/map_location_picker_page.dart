import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:locus_flutter/features/common/presentation/widgets/custom_app_bar.dart';
import 'package:locus_flutter/features/common/presentation/widgets/loading_widget.dart';
import 'package:locus_flutter/features/common/presentation/providers/location_provider.dart';
import 'package:locus_flutter/core/theme/app_theme.dart';
import 'package:locus_flutter/core/services/map/map_service.dart';

class MapLocationPickerPage extends ConsumerStatefulWidget {
  final UniversalLatLng? initialLocation;
  
  const MapLocationPickerPage({
    super.key,
    this.initialLocation,
  });

  @override
  ConsumerState<MapLocationPickerPage> createState() => _MapLocationPickerPageState();
}

class _MapLocationPickerPageState extends ConsumerState<MapLocationPickerPage> {
  UniversalLatLng? _selectedLocation;
  String? _selectedAddress;
  bool _isLoading = false;

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
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Map placeholder - 실제 구현에서는 지도 위젯이 들어갑니다
          _buildMapPlaceholder(),
          
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const LoadingWidget(
                message: '주소를 불러오는 중...',
              ),
            ),
          
          // Selected location info panel
          if (_selectedLocation != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildLocationInfoPanel(),
            ),
          
          // Current location FAB
          Positioned(
            bottom: _selectedLocation != null ? 160 : 80,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => _goToCurrentLocation(currentLocationAsync.value),
              backgroundColor: AppTheme.primaryBlue,
              tooltip: '현재 위치',
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map,
            size: 120,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '지도 보기',
            style: AppTheme.titleLarge.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '실제 앱에서는 여기에 지도가 표시됩니다',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _simulateLocationSelection,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              '임시 위치 선택 (개발용)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedLocation != null 
                ? '선택된 위치:\n${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}'
                : '지도를 탭하여 위치를 선택하세요',
            style: AppTheme.bodySmall.copyWith(
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfoPanel() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppTheme.primaryBlue,
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
                  onPressed: () => setState(() => _selectedLocation = null),
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
            
            // Coordinates
            Container(
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
            ),
            
            // Address
            if (_selectedAddress != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.place,
                      color: AppTheme.primaryBlue,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedAddress!,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _selectedLocation = null),
                    child: const Text('다시 선택'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _confirmSelection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                    ),
                    child: const Text('이 위치 사용'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _simulateLocationSelection() {
    // 임시로 랜덤한 서울 지역 좌표 생성
    final random = DateTime.now().millisecondsSinceEpoch % 1000;
    final lat = 37.5665 + (random / 10000.0); // 서울 근처
    final lng = 126.9780 + (random / 10000.0);
    
    final location = UniversalLatLng(lat, lng);
    setState(() {
      _selectedLocation = location;
    });
    
    _loadAddress(location);
  }

  void _goToCurrentLocation(currentLocation) {
    if (currentLocation != null) {
      setState(() {
        _selectedLocation = currentLocation;
      });
      _loadAddress(currentLocation);
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
    setState(() => _isLoading = true);
    
    try {
      // TODO: 실제 구현에서는 Geocoding 서비스 사용
      await Future.delayed(const Duration(seconds: 1)); // 시뮬레이션
      
      // 임시 주소
      final address = '서울특별시 강남구 역삼동 ${(location.latitude * 1000).toInt()}번지';
      
      if (mounted) {
        setState(() {
          _selectedAddress = address;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _selectedAddress = '주소를 가져올 수 없습니다';
          _isLoading = false;
        });
      }
    }
  }

  void _copyCoordinates() {
    if (_selectedLocation != null) {
      // TODO: 클립보드에 복사 기능 구현
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('좌표가 클립보드에 복사되었습니다'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }

  void _confirmSelection() {
    if (_selectedLocation != null) {
      context.pop(_selectedLocation);
    }
  }
}