import 'package:freezed_annotation/freezed_annotation.dart';

part 'swipe_action.freezed.dart';
part 'swipe_action.g.dart';

@freezed
class SwipeAction with _$SwipeAction {
  const factory SwipeAction({
    required String placeId,
    required SwipeDirection direction,
    required DateTime timestamp,
    String? sessionId,
  }) = _SwipeAction;

  factory SwipeAction.fromJson(Map<String, dynamic> json) =>
      _$SwipeActionFromJson(json);
}

@JsonEnum()
enum SwipeDirection {
  @JsonValue('like')
  like,
  @JsonValue('dislike')
  dislike,
  @JsonValue('skip')
  skip,
}

extension SwipeDirectionExtension on SwipeDirection {
  String get displayName {
    switch (this) {
      case SwipeDirection.like:
        return '좋아요';
      case SwipeDirection.dislike:
        return '싫어요';
      case SwipeDirection.skip:
        return '건너뛰기';
    }
  }

  String get emoji {
    switch (this) {
      case SwipeDirection.like:
        return '💚';
      case SwipeDirection.dislike:
        return '💔';
      case SwipeDirection.skip:
        return '⏭️';
    }
  }
}