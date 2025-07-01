import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locus_flutter/features/place_discovery/domain/entities/place_with_distance.dart';
import 'package:locus_flutter/features/place_discovery/domain/entities/swipe_action.dart';
import 'package:uuid/uuid.dart';

// Swipe session provider
final swipeSessionProvider = StateProvider<String?>((ref) => null);

// Current swipe deck provider
final swipeDeckProvider =
    StateNotifierProvider<SwipeDeckNotifier, SwipeDeckState>(
      (ref) => SwipeDeckNotifier(),
    );

// Swipe deck state
class SwipeDeckState {
  final List<PlaceWithDistance> places;
  final int currentIndex;
  final List<SwipeAction> swipeHistory;
  final String? sessionId;
  final PlaceWithDistance? selectedPlace;
  final bool isComplete;

  const SwipeDeckState({
    this.places = const [],
    this.currentIndex = 0,
    this.swipeHistory = const [],
    this.sessionId,
    this.selectedPlace,
    this.isComplete = false,
  });

  SwipeDeckState copyWith({
    List<PlaceWithDistance>? places,
    int? currentIndex,
    List<SwipeAction>? swipeHistory,
    String? sessionId,
    PlaceWithDistance? selectedPlace,
    bool? isComplete,
  }) {
    return SwipeDeckState(
      places: places ?? this.places,
      currentIndex: currentIndex ?? this.currentIndex,
      swipeHistory: swipeHistory ?? this.swipeHistory,
      sessionId: sessionId ?? this.sessionId,
      selectedPlace: selectedPlace ?? this.selectedPlace,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  PlaceWithDistance? get currentPlace {
    if (currentIndex >= 0 && currentIndex < places.length) {
      return places[currentIndex];
    }
    return null;
  }

  List<PlaceWithDistance> get remainingPlaces {
    if (currentIndex < places.length) {
      return places.sublist(currentIndex);
    }
    return [];
  }

  bool get hasMorePlaces => currentIndex < places.length;

  int get remainingCount =>
      (places.length - currentIndex).clamp(0, places.length);

  double get progress => places.isEmpty ? 0.0 : currentIndex / places.length;
}

class SwipeDeckNotifier extends StateNotifier<SwipeDeckState> {
  SwipeDeckNotifier() : super(const SwipeDeckState());

  void initializeDeck(List<PlaceWithDistance> places) {
    final sessionId = const Uuid().v4();
    state = SwipeDeckState(
      places: places,
      currentIndex: 0,
      swipeHistory: [],
      sessionId: sessionId,
      selectedPlace: null,
      isComplete: false,
    );
  }

  Future<void> swipeRight() async {
    await _performSwipe(SwipeDirection.like);
  }

  Future<void> swipeLeft() async {
    await _performSwipe(SwipeDirection.dislike);
  }

  Future<void> skip() async {
    await _performSwipe(SwipeDirection.skip);
  }

  Future<void> _performSwipe(SwipeDirection direction) async {
    final currentPlace = state.currentPlace;
    if (currentPlace == null || state.sessionId == null) return;

    // Create swipe action for history
    final swipeAction = SwipeAction(
      placeId: currentPlace.place.id,
      direction: direction,
      timestamp: DateTime.now(),
      sessionId: state.sessionId,
    );

    // Update state
    final newSwipeHistory = [...state.swipeHistory, swipeAction];
    final newIndex = state.currentIndex + 1;

    if (direction == SwipeDirection.like) {
      // If liked, mark as selected and complete the session
      state = state.copyWith(
        currentIndex: newIndex,
        swipeHistory: newSwipeHistory,
        selectedPlace: currentPlace,
        isComplete: true,
      );
    } else {
      // Continue with next place or complete if no more places
      final isComplete = newIndex >= state.places.length;
      state = state.copyWith(
        currentIndex: newIndex,
        swipeHistory: newSwipeHistory,
        isComplete: isComplete,
      );
    }
  }

  void undoLastSwipe() {
    if (state.swipeHistory.isEmpty || state.currentIndex <= 0) return;

    final newSwipeHistory = state.swipeHistory.sublist(
      0,
      state.swipeHistory.length - 1,
    );
    final newIndex = state.currentIndex - 1;

    state = state.copyWith(
      currentIndex: newIndex,
      swipeHistory: newSwipeHistory,
      selectedPlace: null,
      isComplete: false,
    );
  }

  void resetDeck() {
    state = const SwipeDeckState();
  }

  void completeDeckManually(PlaceWithDistance selectedPlace) {
    state = state.copyWith(selectedPlace: selectedPlace, isComplete: true);
  }
}
