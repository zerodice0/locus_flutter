import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:locus_flutter/features/place_discovery/domain/entities/place_with_distance.dart';
import 'package:locus_flutter/features/place_discovery/presentation/providers/swipe_provider.dart';
import 'package:locus_flutter/features/place_discovery/presentation/widgets/swipeable_card.dart';

class CardSwipePage extends ConsumerStatefulWidget {
  final List<PlaceWithDistance> places;

  const CardSwipePage({
    super.key,
    required this.places,
  });

  @override
  ConsumerState<CardSwipePage> createState() => _CardSwipePageState();
}

class _CardSwipePageState extends ConsumerState<CardSwipePage> {
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
      body: swipeDeck.isComplete
          ? _buildCompletionView(swipeDeck.selectedPlace)
          : _buildSwipeView(swipeDeck),
    );
  }

  Widget _buildSwipeView(SwipeDeckState swipeDeck) {
    if (swipeDeck.places.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '근처에 저장된 장소가 없습니다',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Progress indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${swipeDeck.currentIndex + 1} / ${swipeDeck.places.length}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '남은 장소: ${swipeDeck.remainingCount}개',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: swipeDeck.progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),

        // Card stack
        Expanded(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Stack(
                children: _buildCardStack(swipeDeck),
              ),
            ),
          ),
        ),

        // Action buttons
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.close,
                color: Colors.red,
                onPressed: () => ref.read(swipeDeckProvider.notifier).swipeLeft(),
                label: '싫어요',
              ),
              _buildActionButton(
                icon: Icons.skip_next,
                color: Colors.grey,
                onPressed: () => ref.read(swipeDeckProvider.notifier).skip(),
                label: '건너뛰기',
              ),
              _buildActionButton(
                icon: Icons.favorite,
                color: Colors.green,
                onPressed: () => ref.read(swipeDeckProvider.notifier).swipeRight(),
                label: '좋아요',
              ),
            ],
          ),
        ),

        // Undo button
        if (swipeDeck.swipeHistory.isNotEmpty)
          Container(
            padding: const EdgeInsets.only(bottom: 20),
            child: TextButton.icon(
              onPressed: () => ref.read(swipeDeckProvider.notifier).undoLastSwipe(),
              icon: const Icon(Icons.undo),
              label: const Text('이전으로'),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildCardStack(SwipeDeckState swipeDeck) {
    final cards = <Widget>[];
    final remainingPlaces = swipeDeck.remainingPlaces;

    // Show up to 3 cards in the stack
    for (int i = min(2, remainingPlaces.length - 1); i >= 0; i--) {
      final place = remainingPlaces[i];
      final isTopCard = i == 0;

      cards.add(
        SwipeableCard(
          key: ValueKey(place.place.id),
          placeWithDistance: place,
          isTopCard: isTopCard,
          onSwipeLeft: () => ref.read(swipeDeckProvider.notifier).swipeLeft(),
          onSwipeRight: () => ref.read(swipeDeckProvider.notifier).swipeRight(),
          onTap: isTopCard ? () => _showPlaceDetails(place) : null,
        ),
      );
    }

    return cards;
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
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
            const Icon(
              Icons.check_circle,
              size: 100,
              color: Colors.green,
            ),
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
                    Text(
                      selectedPlace.place.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedPlace.formattedDistance,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    if (selectedPlace.place.address?.isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      Text(
                        selectedPlace.place.address ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
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
            const Icon(
              Icons.sentiment_neutral,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              '선택된 장소가 없습니다',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.grey,
              ),
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
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
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
                      Text(
                        place.place.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        place.formattedDistance,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      if (place.place.address?.isNotEmpty == true) ...[
                        const SizedBox(height: 16),
                        Text(
                          '주소',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(place.place.address ?? ''),
                      ],
                      if (place.place.description?.isNotEmpty == true) ...[
                        const SizedBox(height: 16),
                        Text(
                          '설명',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
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
    // TODO: Implement navigation to maps app
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${place.place.name}으로 길찾기를 시작합니다'),
      ),
    );
  }

  int min(int a, int b) => a < b ? a : b;
}