import 'package:locus_flutter/core/services/map/map_service.dart';
import 'package:locus_flutter/core/services/map/google_map_service.dart';
import 'package:locus_flutter/core/services/map/naver_map_service.dart';
import 'package:locus_flutter/core/services/map/map_provider_service.dart';
import 'package:locus_flutter/core/services/location/location_service.dart';
import 'package:locus_flutter/core/services/location/geocoding_service.dart';

class MapServiceFactory {
  static MapService create(
    MapProvider provider, {
    required LocationService locationService,
    required GeocodingService geocodingService,
    UniversalLatLng? currentLocation,
  }) {
    MapProvider actualProvider = provider;
    
    // Auto 모드인 경우 현재 위치를 기반으로 최적 제공자 선택
    if (provider == MapProvider.auto && currentLocation != null) {
      actualProvider = MapProviderService.getOptimalProvider(
        currentLocation.latitude,
        currentLocation.longitude,
      );
    }
    
    switch (actualProvider) {
      case MapProvider.naver:
        return NaverMapService(
          locationService: locationService,
          geocodingService: geocodingService,
        );
      case MapProvider.google:
        return GoogleMapService(
          locationService: locationService,
          geocodingService: geocodingService,
        );
      case MapProvider.auto:
        // Auto 모드에서 위치가 없는 경우 기본적으로 Google Maps 사용
        return GoogleMapService(
          locationService: locationService,
          geocodingService: geocodingService,
        );
    }
  }
  
  static Future<MapService> createWithLocationDetection({
    MapProvider provider = MapProvider.auto,
    required LocationService locationService,
    required GeocodingService geocodingService,
  }) async {
    UniversalLatLng? currentLocation;
    
    // 위치 정보를 가져와서 최적 제공자 결정
    if (provider == MapProvider.auto) {
      try {
        final position = await locationService.getCurrentPosition();
        currentLocation = UniversalLatLng(position.latitude, position.longitude);
      } catch (e) {
        // 위치를 가져올 수 없는 경우 기본값 사용
        currentLocation = null;
      }
    }
    
    return create(
      provider,
      locationService: locationService,
      geocodingService: geocodingService,
      currentLocation: currentLocation,
    );
  }
  
  static List<MapProvider> getSupportedProviders() {
    return [MapProvider.auto, MapProvider.naver, MapProvider.google];
  }
  
  static bool isProviderAvailable(MapProvider provider) {
    switch (provider) {
      case MapProvider.naver:
        // Naver Maps는 한국에서만 사용 가능
        return true; // 실제로는 API 키 유무 등을 확인해야 함
      case MapProvider.google:
        // Google Maps는 전 세계에서 사용 가능
        return true; // 실제로는 API 키 유무 등을 확인해야 함
      case MapProvider.auto:
        return true;
    }
  }
  
  static String getProviderDisplayName(MapProvider provider) {
    return MapProviderService.getProviderName(provider);
  }
  
  static String getProviderDescription(MapProvider provider) {
    return MapProviderService.getProviderDescription(provider);
  }
}