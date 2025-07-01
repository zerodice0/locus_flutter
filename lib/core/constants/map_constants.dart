class MapConstants {
  // 한국 지역 경계
  static const double koreaLatMin = 33.0;
  static const double koreaLatMax = 38.9;
  static const double koreaLngMin = 124.0;
  static const double koreaLngMax = 132.0;
  
  // 기본 지도 설정
  static const double defaultZoom = 15.0;
  static const double minZoom = 5.0;
  static const double maxZoom = 20.0;
  
  // 서울 중심 좌표 (기본 위치)
  static const double seoulLatitude = 37.5665;
  static const double seoulLongitude = 126.9780;
  
  // 부산 중심 좌표
  static const double busanLatitude = 35.1796;
  static const double busanLongitude = 129.0756;
  
  // 지도 애니메이션 설정
  static const Duration mapAnimationDuration = Duration(milliseconds: 500);
  
  // 마커 클러스터링 설정
  static const double clusterDistance = 100.0; // 픽셀 단위
  static const int maxMarkersBeforeCluster = 50;
  
  // 검색 반경 설정
  static const List<double> searchRadiusOptions = [
    0.5, 1.0, 2.0, 5.0, 10.0, 20.0, 50.0
  ];
  static const double defaultSearchRadius = 2.0;
  static const double maxSearchRadius = 100.0;
  
  // 지도 타일 설정
  static const String naverMapTileUrl = 'https://naveropenapi.apigw.ntruss.com/map-tile/v1/';
  static const String googleMapApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  static const String naverMapClientId = 'YOUR_NAVER_MAP_CLIENT_ID';
  static const String naverMapClientSecret = 'YOUR_NAVER_MAP_CLIENT_SECRET';
  
  // 지도 스타일
  static const String lightMapStyle = '''
    [
      {
        "featureType": "poi",
        "elementType": "labels",
        "stylers": [{"visibility": "off"}]
      }
    ]
  ''';
  
  static const String darkMapStyle = '''
    [
      {
        "featureType": "all",
        "elementType": "geometry",
        "stylers": [{"color": "#242f3e"}]
      },
      {
        "featureType": "all",
        "elementType": "labels.text.stroke",
        "stylers": [{"lightness": -80}]
      },
      {
        "featureType": "administrative",
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#746855"}]
      }
    ]
  ''';
  
  // 마커 아이콘 설정
  static const String defaultMarkerAsset = 'assets/icons/marker_default.png';
  static const String selectedMarkerAsset = 'assets/icons/marker_selected.png';
  static const String userLocationMarkerAsset = 'assets/icons/marker_user.png';
  
  // 카테고리별 마커 색상
  static const Map<String, String> categoryMarkerColors = {
    'cat_restaurant': '#2196F3',      // Blue
    'cat_cafe': '#8D6E63',            // Brown
    'cat_shopping': '#E91E63',        // Pink
    'cat_entertainment': '#9C27B0',   // Purple
    'cat_travel': '#4CAF50',          // Green
    'cat_healthcare': '#F44336',      // Red
    'cat_education': '#607D8B',       // Blue Grey
    'cat_other': '#9E9E9E',          // Grey
  };
  
  // 거리 단위 변환
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1.0) {
      return '${(distanceInKm * 1000).round()}m';
    } else if (distanceInKm < 10.0) {
      return '${distanceInKm.toStringAsFixed(1)}km';
    } else {
      return '${distanceInKm.round()}km';
    }
  }
  
  // 줌 레벨에 따른 적절한 검색 반경 계산
  static double getSearchRadiusForZoom(double zoom) {
    if (zoom >= 18) return 0.5;
    if (zoom >= 16) return 1.0;
    if (zoom >= 14) return 2.0;
    if (zoom >= 12) return 5.0;
    if (zoom >= 10) return 10.0;
    return 20.0;
  }
  
  // 두 좌표 사이의 중심점 계산
  static Map<String, double> getCenterPoint(
    double lat1, double lng1, 
    double lat2, double lng2
  ) {
    return {
      'latitude': (lat1 + lat2) / 2,
      'longitude': (lng1 + lng2) / 2,
    };
  }
  
  // 여러 좌표의 경계 계산
  static Map<String, double> getBounds(List<Map<String, double>> coordinates) {
    if (coordinates.isEmpty) {
      return {
        'minLat': seoulLatitude,
        'maxLat': seoulLatitude,
        'minLng': seoulLongitude,
        'maxLng': seoulLongitude,
      };
    }
    
    double minLat = coordinates.first['latitude']!;
    double maxLat = coordinates.first['latitude']!;
    double minLng = coordinates.first['longitude']!;
    double maxLng = coordinates.first['longitude']!;
    
    for (final coord in coordinates) {
      final lat = coord['latitude']!;
      final lng = coord['longitude']!;
      
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }
    
    return {
      'minLat': minLat,
      'maxLat': maxLat,
      'minLng': minLng,
      'maxLng': maxLng,
    };
  }
}