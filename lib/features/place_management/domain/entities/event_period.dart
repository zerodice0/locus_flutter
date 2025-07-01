import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_period.freezed.dart';

@freezed
class EventPeriod with _$EventPeriod {
  const factory EventPeriod({
    required String id,
    required String placeId,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    String? description,
  }) = _EventPeriod;

  const EventPeriod._();

  // Helper methods
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  bool get isUpcoming {
    final now = DateTime.now();
    return now.isBefore(startDate);
  }

  bool get isExpired {
    final now = DateTime.now();
    return now.isAfter(endDate);
  }

  Duration get duration => endDate.difference(startDate);

  int get daysRemaining {
    if (isExpired) return 0;
    final now = DateTime.now();
    final targetDate = isUpcoming ? startDate : endDate;
    return targetDate.difference(now).inDays;
  }

  String get statusText {
    if (isActive) return '진행 중';
    if (isUpcoming) return '예정';
    return '종료';
  }
}