import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:locus_flutter/features/place_discovery/domain/entities/place_with_distance.dart';
import 'package:locus_flutter/features/place_discovery/presentation/providers/swipe_provider.dart';
import 'package:locus_flutter/features/place_discovery/presentation/widgets/swipeable_list_item.dart';

class ListSwipePage extends ConsumerStatefulWidget {
  final List<PlaceWithDistance> places;

  const ListSwipePage({super.key, required this.places});

  @override
  ConsumerState<ListSwipePage> createState() => _ListSwipePageState();
}

class _ListSwipePageState extends ConsumerState<ListSwipePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(swipeDeckProvider.notifier).initializeDeck(widget.places);
    });
  }

  @override
  Widget build(BuildContext context) {
    final swipeDeck = ref.watch(swipeDeckProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('장소 선택'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/search-settings'),
          ),
        ],
      ),
      body:
          swipeDeck.isComplete
              ? _buildCompletionView(swipeDeck.selectedPlace)
              : _buildListView(swipeDeck),
    );
  }

  Widget _buildListView(SwipeDeckState swipeDeck) {
    if (swipeDeck.places.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '근처에 저장된 장소가 없습니다',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Progress header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '장소 선택 (${swipeDeck.currentIndex} / ${swipeDeck.places.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '남은 장소: ${swipeDeck.remainingCount}개',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: swipeDeck.progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '좌우로 스와이프하여 선택하세요 (왼쪽: 싫어요, 오른쪽: 좋아요)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // Places list
        Expanded(
          child:
              swipeDeck.remainingPlaces.isEmpty
                  ? const Center(child: Text('모든 장소를 확인했습니다'))
                  : ListView.builder(
                    itemCount: swipeDeck.remainingPlaces.length,
                    itemBuilder: (context, index) {
                      final place = swipeDeck.remainingPlaces[index];
                      final isCurrentPlace = index == 0;

                      return AnimatedOpacity(
                        opacity: isCurrentPlace ? 1.0 : 0.6,
                        duration: const Duration(milliseconds: 300),
                        child: SwipeableListItem(
                          key: ValueKey(place.place.id),
                          placeWithDistance: place,
                          onSwipeLeft:
                              isCurrentPlace
                                  ? () =>
                                      ref
                                          .read(swipeDeckProvider.notifier)
                                          .swipeLeft()
                                  : null,
                          onSwipeRight:
                              isCurrentPlace
                                  ? () =>
                                      ref
                                          .read(swipeDeckProvider.notifier)
                                          .swipeRight()
                                  : null,
                          onTap: () => _showPlaceDetails(place),
                        ),
                      );
                    },
                  ),
        ),

        // Action buttons
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          () =>
                              ref.read(swipeDeckProvider.notifier).swipeLeft(),
                      icon: const Icon(Icons.close),
                      label: const Text('싫어요'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          () => ref.read(swipeDeckProvider.notifier).skip(),
                      icon: const Icon(Icons.skip_next),
                      label: const Text('건너뛰기'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          () =>
                              ref.read(swipeDeckProvider.notifier).swipeRight(),
                      icon: const Icon(Icons.favorite),
                      label: const Text('좋아요'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              if (swipeDeck.swipeHistory.isNotEmpty) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed:
                      () =>
                          ref.read(swipeDeckProvider.notifier).undoLastSwipe(),
                  icon: const Icon(Icons.undo),
                  label: const Text('이전으로'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionView(PlaceWithDistance? selectedPlace) {
    if (selectedPlace != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            Text(
              '선택 완료!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _getCategoryColor(
                              selectedPlace.place.categoryId,
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(
                            _getCategoryIcon(selectedPlace.place.categoryId),
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedPlace.place.name,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedPlace.formattedDistance,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              if (selectedPlace.place.address?.isNotEmpty ==
                                  true) ...[
                                const SizedBox(height: 4),
                                Text(
                                  selectedPlace.place.address ?? '',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    child: const Text('완료'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _openInMaps(selectedPlace),
                    child: const Text('길찾기'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sentiment_neutral, size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              '선택된 장소가 없습니다',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text(
              '모든 장소를 건너뛰거나 싫어했습니다.\n다른 설정으로 다시 시도해보세요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }
  }

  void _showPlaceDetails(PlaceWithDistance place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            maxChildSize: 0.9,
            minChildSize: 0.3,
            builder:
                (context, scrollController) => Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: _getCategoryColor(
                                        place.place.categoryId,
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Icon(
                                      _getCategoryIcon(place.place.categoryId),
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          place.place.name,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.headlineSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          place.formattedDistance,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium?.copyWith(
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              if (place.place.address?.isNotEmpty == true) ...[
                                const SizedBox(height: 24),
                                Text(
                                  '주소',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(place.place.address ?? ''),
                              ],

                              if (place.place.description?.isNotEmpty ==
                                  true) ...[
                                const SizedBox(height: 16),
                                Text(
                                  '설명',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(place.place.description ?? ''),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  void _openInMaps(PlaceWithDistance place) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${place.place.name}으로 길찾기를 시작합니다')));
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
