import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:locus_flutter/features/common/presentation/widgets/custom_app_bar.dart';
import 'package:locus_flutter/features/common/presentation/widgets/loading_widget.dart';
import 'package:locus_flutter/features/common/presentation/widgets/error_widget.dart';
import 'package:locus_flutter/features/common/presentation/widgets/empty_state_widget.dart';
import 'package:locus_flutter/features/place_management/presentation/providers/place_provider.dart';
import 'package:locus_flutter/features/place_management/presentation/widgets/place_card.dart';
import 'package:locus_flutter/features/common/presentation/providers/location_provider.dart';
import 'package:locus_flutter/core/theme/app_theme.dart';

class PlaceListPage extends ConsumerStatefulWidget {
  const PlaceListPage({super.key});

  @override
  ConsumerState<PlaceListPage> createState() => _PlaceListPageState();
}

class _PlaceListPageState extends ConsumerState<PlaceListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final placesAsync = ref.watch(placesProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final currentLocationAsync = ref.watch(currentLocationProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: '저장된 장소',
        actions: [
          IconButton(
            onPressed: () => _showSearchDialog(context),
            icon: const Icon(Icons.search),
            tooltip: '검색',
          ),
          IconButton(
            onPressed: () => ref.read(placesProvider.notifier).refreshPlaces(),
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar (if searching)
          if (searchQuery.isNotEmpty) _buildSearchBar(),
          
          // Places list
          Expanded(
            child: placesAsync.when(
              data: (places) {
                if (places.isEmpty) {
                  return EmptyStateWidget.noPlaces(
                    onAddPlace: () => context.go('/add-place'),
                  );
                }

                final filteredPlaces = searchQuery.isEmpty 
                    ? places 
                    : places.where((place) =>
                        place.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                        (place.description?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
                        (place.address?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false)
                      ).toList();

                if (filteredPlaces.isEmpty && searchQuery.isNotEmpty) {
                  return EmptyStateWidget.noSearchResults(
                    onRetry: () => ref.read(searchQueryProvider.notifier).state = '',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(placesProvider.notifier).refreshPlaces(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredPlaces.length,
                    itemBuilder: (context, index) {
                      final place = filteredPlaces[index];
                      final distanceFromUser = _calculateDistance(
                        place, 
                        currentLocationAsync.value,
                      );
                      
                      return PlaceCard(
                        place: place,
                        distanceFromUser: distanceFromUser,
                        onTap: () => _showPlaceDetail(place.id),
                        onEdit: () => _editPlace(place.id),
                        onDelete: () => _deletePlace(place.id),
                        onVisit: () => _visitPlace(place.id),
                      );
                    },
                  ),
                );
              },
              loading: () => const LoadingWidget(
                message: '장소 목록을 불러오는 중...',
              ),
              error: (error, stackTrace) => CustomErrorWidget.generic(
                message: error.toString(),
                onRetry: () => ref.read(placesProvider.notifier).refreshPlaces(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add-place'),
        tooltip: '장소 추가',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    final searchQuery = ref.watch(searchQueryProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController..text = searchQuery,
        decoration: InputDecoration(
          hintText: '장소 검색...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    ref.read(searchQueryProvider.notifier).state = '';
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
        ),
        onChanged: (query) {
          ref.read(searchQueryProvider.notifier).state = query;
        },
      ),
    );
  }

  double? _calculateDistance(place, currentLocation) {
    if (currentLocation == null) return null;
    return place.distanceFrom(currentLocation.latitude, currentLocation.longitude);
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('장소 검색'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: '장소 이름, 설명, 주소로 검색',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
          onSubmitted: (query) {
            ref.read(searchQueryProvider.notifier).state = query;
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(searchQueryProvider.notifier).state = _searchController.text;
              Navigator.of(context).pop();
            },
            child: const Text('검색'),
          ),
        ],
      ),
    );
  }

  void _showPlaceDetail(String placeId) {
    context.push('/place/$placeId');
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
        
        // 목록에서 제거
        ref.read(placesProvider.notifier).removePlace(placeId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('장소가 삭제되었습니다'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
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

  Future<void> _visitPlace(String placeId) async {
    try {
      final incrementVisitUseCase = ref.read(incrementVisitCountUseCaseProvider);
      await incrementVisitUseCase(placeId);
      
      // 목록 새로고침
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
}