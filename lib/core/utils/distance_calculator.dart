import 'dart:math';

class DistanceCalculator {
  static const double earthRadiusKm = 6371.0;

  /// Haversine 공식을 사용하여 두 지점 간의 거리를 킬로미터 단위로 계산
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// 미터 단위로 거리 계산
  static double calculateDistanceInMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return calculateDistance(lat1, lon1, lat2, lon2) * 1000;
  }

  /// 도를 라디안으로 변환
  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// 거리에 따른 적절한 단위로 포맷팅
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      final int meters = (distanceInKm * 1000).round();
      return '${meters}m';
    } else if (distanceInKm < 10) {
      return '${distanceInKm.toStringAsFixed(1)}km';
    } else {
      return '${distanceInKm.round()}km';
    }
  }

  /// 특정 반경 내에 있는지 확인
  static bool isWithinRadius(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
    double radiusKm,
  ) {
    final double distance = calculateDistance(lat1, lon1, lat2, lon2);
    return distance <= radiusKm;
  }

  /// 여러 장소를 거리순으로 정렬
  static List<T> sortByDistance<T>(
    List<T> places,
    double currentLat,
    double currentLon,
    double Function(T) getLatitude,
    double Function(T) getLongitude,
  ) {
    final List<T> sortedPlaces = List.from(places);
    
    sortedPlaces.sort((a, b) {
      final double distanceA = calculateDistance(
        currentLat,
        currentLon,
        getLatitude(a),
        getLongitude(a),
      );
      final double distanceB = calculateDistance(
        currentLat,
        currentLon,
        getLatitude(b),
        getLongitude(b),
      );
      return distanceA.compareTo(distanceB);
    });

    return sortedPlaces;
  }

  /// 적응형 검색 반경 계산 (장소 밀도에 따라 조정)
  static double calculateAdaptiveRadius(
    int nearbyPlacesCount,
    double baseRadiusKm,
  ) {
    if (nearbyPlacesCount == 0) {
      return baseRadiusKm * 3; // 3배로 확장
    } else if (nearbyPlacesCount < 3) {
      return baseRadiusKm * 2; // 2배로 확장
    } else if (nearbyPlacesCount > 20) {
      return baseRadiusKm * 0.5; // 절반으로 축소
    }
    return baseRadiusKm; // 기본 반경 유지
  }
}