import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:locus_flutter/features/place_discovery/presentation/providers/search_provider.dart';
import 'package:locus_flutter/features/common/presentation/widgets/loading_widget.dart';

class PlaceDiscoveryPage extends ConsumerStatefulWidget {
  const PlaceDiscoveryPage({super.key});

  @override
  ConsumerState<PlaceDiscoveryPage> createState() => _PlaceDiscoveryPageState();
}

class _PlaceDiscoveryPageState extends ConsumerState<PlaceDiscoveryPage> {
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    final searchSettings = ref.watch(searchSettingsProvider);
    final nearbyPlaces = ref.watch(nearbyPlacesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('장소 탐색'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/search-settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search settings summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      '검색 설정',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.push('/search-settings'),
                      child: const Text('변경'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildSettingChip(
                      icon: Icons.radio_button_unchecked,
                      label: '반경 ${searchSettings.radiusKm}km',
                    ),
                    const SizedBox(width: 8),
                    _buildSettingChip(
                      icon: Icons.category,
                      label: searchSettings.categoryIds.isEmpty 
                          ? '모든 카테고리' 
                          : '${searchSettings.categoryIds.length}개 카테고리',
                    ),
                    const SizedBox(width: 8),
                    _buildSettingChip(
                      icon: Icons.sort,
                      label: '거리순',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: nearbyPlaces.when(
              data: (places) => _buildSearchResults(places),
              loading: () => const LoadingWidget(message: '근처 장소를 검색하는 중...'),
              error: (error, _) => _buildErrorView(error),
            ),
          ),

          // Search button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSearching ? null : _searchNearbyPlaces,
                icon: _isSearching 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.search),
                label: Text(_isSearching ? '검색 중...' : '근처 장소 찾기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List places) {
    if (places.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '근처 장소 찾기를 시작하세요',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '아래 버튼을 눌러 탐색을 시작해보세요!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                '${places.length}개의 장소를 찾았습니다',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action buttons
          if (places.length >= 3) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/card-swipe', extra: places),
                icon: const Icon(Icons.style),
                label: const Text('카드 스타일로 선택'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/list-swipe', extra: places),
              icon: const Icon(Icons.list),
              label: const Text('리스트 스타일로 선택'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Place preview
          Text(
            '미리보기',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              itemCount: places.length > 5 ? 5 : places.length,
              itemBuilder: (context, index) {
                final place = places[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getCategoryColor(place.place.categoryId),
                      child: Icon(
                        _getCategoryIcon(place.place.categoryId),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(place.place.name),
                    subtitle: Text(place.formattedDistance),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                );
              },
            ),
          ),

          if (places.length > 5)
            Center(
              child: Text(
                '그 외 ${places.length - 5}개 장소가 더 있습니다',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorView(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            '검색 중 오류가 발생했습니다',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _searchNearbyPlaces,
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Future<void> _searchNearbyPlaces() async {
    setState(() {
      _isSearching = true;
    });

    try {
      // 임시로 서울 시청 좌표 사용 (실제 구현에서는 GPS 위치 사용)
      await ref.read(nearbyPlacesProvider.notifier).searchPlaces(
        currentLat: 37.5665,
        currentLng: 126.9780,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('검색 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Color _getCategoryColor(String categoryId) {
    switch (categoryId) {
      case 'cat_restaurant':
        return const Color(0xFF2196F3);
      case 'cat_cafe':
        return const Color(0xFF8D6E63);
      case 'cat_shopping':
        return const Color(0xFFE91E63);
      case 'cat_entertainment':
        return const Color(0xFF9C27B0);
      case 'cat_travel':
        return const Color(0xFF4CAF50);
      case 'cat_healthcare':
        return const Color(0xFFF44336);
      case 'cat_education':
        return const Color(0xFF607D8B);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'cat_restaurant':
        return Icons.restaurant;
      case 'cat_cafe':
        return Icons.local_cafe;
      case 'cat_shopping':
        return Icons.shopping_bag;
      case 'cat_entertainment':
        return Icons.movie;
      case 'cat_travel':
        return Icons.place;
      case 'cat_healthcare':
        return Icons.local_hospital;
      case 'cat_education':
        return Icons.school;
      default:
        return Icons.category;
    }
  }
}