import 'package:locus_flutter/core/utils/distance_calculator.dart';
import 'package:locus_flutter/features/place_discovery/domain/entities/place_with_distance.dart';
import 'package:locus_flutter/features/place_management/domain/entities/place.dart';

class CalculateDistance {
  PlaceWithDistance call({
    required Place place,
    required double currentLat,
    required double currentLng,
  }) {
    final double distanceKm = DistanceCalculator.calculateDistance(
      currentLat,
      currentLng,
      place.latitude,
      place.longitude,
    );

    final String formattedDistance = DistanceCalculator.formatDistance(distanceKm);

    return PlaceWithDistance(
      place: place,
      distanceKm: distanceKm,
      formattedDistance: formattedDistance,
    );
  }

  List<PlaceWithDistance> calculateForPlaces({
    required List<Place> places,
    required double currentLat,
    required double currentLng,
  }) {
    return places.map((place) => call(
      place: place,
      currentLat: currentLat,
      currentLng: currentLng,
    )).toList();
  }
}