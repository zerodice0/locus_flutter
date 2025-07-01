import 'package:freezed_annotation/freezed_annotation.dart';

part 'operating_hours.freezed.dart';

@freezed
class OperatingHours with _$OperatingHours {
  const factory OperatingHours({
    required String id,
    required String placeId,
    required int dayOfWeek, // 0-6 (Sunday-Saturday)
    String? openTime, // HH:mm format
    String? closeTime, // HH:mm format
    required bool isClosed,
  }) = _OperatingHours;

  const OperatingHours._();

  // Helper methods
  bool get isOpen => !isClosed && openTime != null && closeTime != null;
  
  String get displayTime {
    if (isClosed) return '휴무';
    if (openTime == null || closeTime == null) return '시간 미정';
    return '$openTime - $closeTime';
  }

  String get dayName {
    const days = ['일', '월', '화', '수', '목', '금', '토'];
    return days[dayOfWeek];
  }

  bool isOpenAt(DateTime dateTime) {
    if (isClosed || openTime == null || closeTime == null) return false;
    
    final currentTime = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return currentTime.compareTo(openTime!) >= 0 && currentTime.compareTo(closeTime!) <= 0;
  }
}