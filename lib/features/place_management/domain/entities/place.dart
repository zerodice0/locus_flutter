import 'dart:math' as math;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:locus_flutter/features/place_management/domain/entities/category.dart';
import 'package:locus_flutter/features/place_management/domain/entities/operating_hours.dart';
import 'package:locus_flutter/features/place_management/domain/entities/event_period.dart';

part 'place.freezed.dart';

@freezed
class Place with _$Place {
  const factory Place({
    required String id,
    required String name,
    String? description,
    required double latitude,
    required double longitude,
    String? address,
    required String categoryId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isActive,
    String? notes,
    double? rating,
    required int visitCount,
    DateTime? lastVisited,
    String? imagePath,
    // Related data
    Category? category,
    List<OperatingHours>? operatingHours,
    List<EventPeriod>? eventPeriods,
  }) = _Place;

  const Place._();

  // Helper methods
  bool get hasRating => rating != null && rating! > 0;
  
  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;
  
  bool get hasBeenVisited => visitCount > 0;
  
  String get displayRating => rating?.toStringAsFixed(1) ?? 'N/A';
  
  String get visitCountText {
    if (visitCount == 0) return '미방문';
    return '$visitCount회 방문';
  }

  String get createdAtFormatted {
    return '${createdAt.year}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.day.toString().padLeft(2, '0')}';
  }

  String get updatedAtFormatted {
    return '${updatedAt.year}.${updatedAt.month.toString().padLeft(2, '0')}.${updatedAt.day.toString().padLeft(2, '0')}';
  }

  // Check if place is currently open
  bool get isCurrentlyOpen {
    if (operatingHours == null || operatingHours!.isEmpty) return true;
    
    final now = DateTime.now();
    final todayHours = operatingHours!.where((h) => h.dayOfWeek == now.weekday % 7).firstOrNull;
    
    return todayHours?.isOpenAt(now) ?? false;
  }

  // Check if place has active events
  bool get hasActiveEvents {
    if (eventPeriods == null || eventPeriods!.isEmpty) return false;
    return eventPeriods!.any((event) => event.isActive);
  }

  // Get current operating status
  String get operatingStatus {
    if (operatingHours == null || operatingHours!.isEmpty) return '운영시간 정보 없음';
    
    final now = DateTime.now();
    final todayHours = operatingHours!.where((h) => h.dayOfWeek == now.weekday % 7).firstOrNull;
    
    if (todayHours == null) return '운영시간 정보 없음';
    if (todayHours.isClosed) return '오늘 휴무';
    if (todayHours.isOpenAt(now)) return '영업 중';
    return '영업 종료';
  }

  // Calculate distance from a given point
  double distanceFrom(double lat, double lng) {
    // Haversine formula implementation
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double dLat = _degreesToRadians(latitude - lat);
    final double dLng = _degreesToRadians(longitude - lng);
    
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat)) * math.cos(_degreesToRadians(latitude)) *
        math.sin(dLng / 2) * math.sin(dLng / 2);
    
    final double c = 2 * math.asin(math.sqrt(a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  // Create a copy with updated visit information
  Place incrementVisitCount() {
    return copyWith(
      visitCount: visitCount + 1,
      lastVisited: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Create a copy with updated rating
  Place updateRating(double newRating) {
    return copyWith(
      rating: newRating,
      updatedAt: DateTime.now(),
    );
  }
}