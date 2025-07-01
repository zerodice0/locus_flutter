import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:locus_flutter/features/common/presentation/widgets/custom_app_bar.dart';
import 'package:locus_flutter/features/common/presentation/widgets/loading_widget.dart';
import 'package:locus_flutter/features/common/presentation/widgets/error_widget.dart';
import 'package:locus_flutter/features/place_management/presentation/providers/place_provider.dart';
import 'package:locus_flutter/features/place_management/presentation/providers/category_provider.dart';
import 'package:locus_flutter/features/common/presentation/providers/location_provider.dart';
import 'package:locus_flutter/core/theme/app_theme.dart';
import 'package:locus_flutter/core/constants/map_constants.dart';
import 'package:locus_flutter/features/place_management/domain/entities/place.dart';

class PlaceDetailPage extends ConsumerStatefulWidget {
  final String placeId;
  
  const PlaceDetailPage({
    super.key,
    required this.placeId,
  });

  @override
  ConsumerState<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends ConsumerState<PlaceDetailPage> {
  @override
  Widget build(BuildContext context) {
    final placesAsync = ref.watch(placesProvider);
    final currentLocationAsync = ref.watch(currentLocationProvider);
    
    return Scaffold(
      body: placesAsync.when(
        data: (places) {
          final place = places.firstWhere(
            (p) => p.id == widget.placeId,
            orElse: () => throw Exception('Place not found'),
          );
          
          return _buildPlaceDetail(context, place, currentLocationAsync.value);
        },
        loading: () => const Scaffold(
          body: LoadingWidget(message: '장소 정보를 불러오는 중...'),
        ),
        error: (error, stackTrace) => Scaffold(
          appBar: const CustomAppBar(title: '장소 상세'),
          body: CustomErrorWidget.generic(
            message: '장소 정보를 불러올 수 없습니다',
            onRetry: () => ref.refresh(placesProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceDetail(BuildContext context, Place place, currentLocation) {
    final category = ref.read(categoriesProvider.notifier).getCategoryById(place.categoryId);
    final distanceFromUser = currentLocation != null 
        ? place.distanceFrom(currentLocation.latitude, currentLocation.longitude)
        : null;

    return CustomScrollView(
      slivers: [
        // App bar with actions
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              place.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 3,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryBlue,
                    AppTheme.primaryBlue.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Background pattern
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.1),
                      ),
                      child: const Icon(
                        Icons.place,
                        size: 120,
                        color: Colors.white24,
                      ),
                    ),
                  ),
                  // Category icon
                  if (category != null)
                    Positioned(
                      right: 16,
                      bottom: 60,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _getIconData(category.icon),
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => _visitPlace(place.id),
              icon: const Icon(Icons.check_circle_outline),
              tooltip: '방문 체크',
            ),
            IconButton(
              onPressed: () => _editPlace(place.id),
              icon: const Icon(Icons.edit_outlined),
              tooltip: '편집',
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _onMenuSelected(value, place.id),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: AppTheme.errorRed),
                      SizedBox(width: 8),
                      Text('삭제'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        
        // Content
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Basic info card
              _buildBasicInfoCard(place, category, distanceFromUser),
              const SizedBox(height: 16),
              
              // Location card
              _buildLocationCard(place),
              const SizedBox(height: 16),
              
              // Description card
              if (place.description != null && place.description!.isNotEmpty)
                _buildDescriptionCard(place),
              
              // Notes card
              if (place.notes != null && place.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildNotesCard(place),
              ],
              
              // Operating hours card
              if (place.operatingHours != null && place.operatingHours!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildOperatingHoursCard(place),
              ],
              
              // Event periods card
              if (place.eventPeriods != null && place.eventPeriods!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildEventPeriodsCard(place),
              ],
              
              // Statistics card
              const SizedBox(height: 16),
              _buildStatisticsCard(place),
              
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoCard(Place place, category, double? distanceFromUser) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (category != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(int.parse('0xFF${category.color}')).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIconData(category.icon),
                      color: Color(int.parse('0xFF${category.color}')),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    category.name,
                    style: AppTheme.bodyMedium.copyWith(
                      color: Color(int.parse('0xFF${category.color}')),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const Spacer(),
                if (place.hasRating) ...[
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        place.displayRating,
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Operating status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: place.isCurrentlyOpen 
                        ? AppTheme.successGreen.withValues(alpha: 0.2)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    place.operatingStatus,
                    style: AppTheme.bodySmall.copyWith(
                      color: place.isCurrentlyOpen 
                          ? AppTheme.successGreen
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Distance
                if (distanceFromUser != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: AppTheme.primaryBlue,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          MapConstants.formatDistance(distanceFromUser),
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(Place place) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  '위치 정보',
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (place.address != null && place.address!.isNotEmpty) ...[
              Text(
                place.address!,
                style: AppTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
            ],
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
                          '위도: ${place.latitude.toStringAsFixed(6)}',
                          style: AppTheme.bodySmall.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                        Text(
                          '경도: ${place.longitude.toStringAsFixed(6)}',
                          style: AppTheme.bodySmall.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _openInMap(place),
                    icon: const Icon(Icons.open_in_new),
                    tooltip: '지도에서 보기',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(Place place) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '설명',
              style: AppTheme.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              place.description!,
              style: AppTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(Place place) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notes, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  '메모',
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              place.notes!,
              style: AppTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperatingHoursCard(Place place) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  '운영시간',
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...place.operatingHours!.map((hours) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      _getDayOfWeekName(hours.dayOfWeek),
                      style: AppTheme.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hours.isClosed 
                        ? '휴무'
                        : '${hours.openTime} - ${hours.closeTime}',
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildEventPeriodsCard(Place place) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  '이벤트 기간',
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...place.eventPeriods!.map((event) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: event.isActive 
                      ? AppTheme.successGreen.withValues(alpha: 0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${event.startDate.toString().split(' ')[0]} - ${event.endDate.toString().split(' ')[0]}',
                      style: AppTheme.bodySmall,
                    ),
                    if (event.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        event.description!,
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(Place place) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '통계',
              style: AppTheme.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '방문 횟수',
                    place.visitCountText,
                    Icons.check_circle,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '등록일',
                    place.createdAtFormatted,
                    Icons.calendar_today,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '최근 수정',
                    place.updatedAtFormatted,
                    Icons.update,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '상태',
                    place.isActive ? '활성' : '비활성',
                    place.isActive ? Icons.check : Icons.close,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryBlue,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTheme.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'movie':
        return Icons.movie;
      case 'place':
        return Icons.place;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'more_horiz':
      default:
        return Icons.more_horiz;
    }
  }

  String _getDayOfWeekName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return '월';
      case 2:
        return '화';
      case 3:
        return '수';
      case 4:
        return '목';
      case 5:
        return '금';
      case 6:
        return '토';
      case 7:
        return '일';
      default:
        return '';
    }
  }

  void _onMenuSelected(String value, String placeId) {
    switch (value) {
      case 'delete':
        _deletePlace(placeId);
        break;
    }
  }

  Future<void> _visitPlace(String placeId) async {
    try {
      final incrementVisitUseCase = ref.read(incrementVisitCountUseCaseProvider);
      await incrementVisitUseCase(placeId);
      
      await ref.read(placesProvider.notifier).refreshPlaces();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('방문 체크되었습니다'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('방문 체크 중 오류가 발생했습니다: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _editPlace(String placeId) {
    context.push('/edit-place/$placeId');
  }

  Future<void> _deletePlace(String placeId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('장소 삭제'),
        content: const Text('이 장소를 삭제하시겠습니까?\n삭제된 장소는 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final deletePlaceUseCase = ref.read(deletePlaceUseCaseProvider);
        await deletePlaceUseCase(placeId);
        
        ref.read(placesProvider.notifier).removePlace(placeId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('장소가 삭제되었습니다'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('삭제 중 오류가 발생했습니다: $e'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    }
  }

  void _openInMap(Place place) async {
    final lat = place.latitude;
    final lng = place.longitude;
    final name = Uri.encodeComponent(place.name);
    
    // 지도 앱 URL 생성 (iOS: Apple Maps, Android: Google Maps)
    final appleMapUrl = 'http://maps.apple.com/?q=$name&ll=$lat,$lng';
    final googleMapUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    
    try {
      // iOS는 Apple Maps, Android는 Google Maps 시도
      final url = Theme.of(context).platform == TargetPlatform.iOS 
          ? appleMapUrl 
          : googleMapUrl;
      
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        // 기본 지도 앱이 없는 경우 브라우저에서 Google Maps 열기
        final fallbackUrl = 'https://maps.google.com/?q=$lat,$lng';
        await launchUrl(Uri.parse(fallbackUrl), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('지도 앱을 열 수 없습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}