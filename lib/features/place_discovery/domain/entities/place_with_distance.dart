import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:locus_flutter/features/place_management/domain/entities/place.dart';

part 'place_with_distance.freezed.dart';

@freezed
class PlaceWithDistance with _$PlaceWithDistance {
  const factory PlaceWithDistance({
    required Place place,
    required double distanceKm,
    required String formattedDistance,
  }) = _PlaceWithDistance;
}

extension PlaceWithDistanceExtension on PlaceWithDistance {
  bool get isNearby => distanceKm <= 0.5; // 500m 이내
  bool get isVeryClose => distanceKm <= 0.1; // 100m 이내
  
  String get proximityLabel {
    if (isVeryClose) return '매우 가까움';
    if (isNearby) return '가까움';
    if (distanceKm <= 2.0) return '보통';
    return '멀음';
  }
}