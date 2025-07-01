import 'package:locus_flutter/core/services/map/map_service.dart';
import 'package:locus_flutter/core/constants/map_constants.dart';

class MapProviderService {
  static MapProvider getOptimalProvider(double latitude, double longitude) {
    // 한국 영역 체크
    if (latitude >= MapConstants.koreaLatMin && 
        latitude <= MapConstants.koreaLatMax && 
        longitude >= MapConstants.koreaLngMin && 
        longitude <= MapConstants.koreaLngMax) {
      return MapProvider.naver;
    }
    return MapProvider.google;
  }
  
  static bool isInKorea(double latitude, double longitude) {
    return latitude >= MapConstants.koreaLatMin && 
           latitude <= MapConstants.koreaLatMax && 
           longitude >= MapConstants.koreaLngMin && 
           longitude <= MapConstants.koreaLngMax;
  }
  
  static String getProviderName(MapProvider provider) {
    switch (provider) {
      case MapProvider.naver:
        return 'Naver Maps';
      case MapProvider.google:
        return 'Google Maps';
      case MapProvider.auto:
        return '자동 선택';
    }
  }
  
  static String getProviderDescription(MapProvider provider) {
    switch (provider) {
      case MapProvider.naver:
        return '한국 지역 최적화';
      case MapProvider.google:
        return '전 세계 지원';
      case MapProvider.auto:
        return '위치에 따라 자동 선택';
    }
  }
  
  static List<MapProvider> getAvailableProviders() {
    return [MapProvider.auto, MapProvider.naver, MapProvider.google];
  }
}