import 'package:locus_flutter/features/place_discovery/domain/entities/swipe_action.dart';
import 'package:locus_flutter/features/place_discovery/domain/repositories/search_repository.dart';

class RecordSwipeAction {
  final SearchRepository repository;

  RecordSwipeAction(this.repository);

  Future<void> call({
    required String placeId,
    required SwipeDirection direction,
    String? sessionId,
  }) async {
    final SwipeAction action = SwipeAction(
      placeId: placeId,
      direction: direction,
      timestamp: DateTime.now(),
      sessionId: sessionId,
    );

    await repository.recordSwipeAction(action);
  }

  Future<void> recordLike(String placeId, {String? sessionId}) async {
    await call(
      placeId: placeId,
      direction: SwipeDirection.like,
      sessionId: sessionId,
    );
  }

  Future<void> recordDislike(String placeId, {String? sessionId}) async {
    await call(
      placeId: placeId,
      direction: SwipeDirection.dislike,
      sessionId: sessionId,
    );
  }

  Future<void> recordSkip(String placeId, {String? sessionId}) async {
    await call(
      placeId: placeId,
      direction: SwipeDirection.skip,
      sessionId: sessionId,
    );
  }
}