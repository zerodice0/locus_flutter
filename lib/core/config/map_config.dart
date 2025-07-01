import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapConfig {
  // Google Maps API Key - .env 파일에서 읽기
  static String get googleMapsApiKey {
    final key = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('GOOGLE_MAPS_API_KEY not found in .env file');
    }
    return key;
  }

  // Naver Maps API Keys - .env 파일에서 읽기
  static String get naverMapsClientId {
    final key = dotenv.env['NAVER_MAPS_CLIENT_ID'];
    if (key == null || key.isEmpty) {
      throw Exception('NAVER_MAPS_CLIENT_ID not found in .env file');
    }
    return key;
  }

  static String get naverMapsClientSecret {
    final key = dotenv.env['NAVER_MAPS_CLIENT_SECRET'];
    if (key == null || key.isEmpty) {
      throw Exception('NAVER_MAPS_CLIENT_SECRET not found in .env file');
    }
    return key;
  }

  // 개발 모드에서는 API 키가 설정되어 있는지 확인
  static bool get isConfigured {
    return googleMapsApiKey.isNotEmpty &&
           naverMapsClientId.isNotEmpty &&
           naverMapsClientSecret.isNotEmpty;
  }

  // 디버그 정보 (API 키는 마스킹)
  static String get debugInfo {
    return '''
MapConfig Debug Info:
- Google Maps API Key: ${_maskApiKey(googleMapsApiKey)}
- Naver Maps Client ID: ${_maskApiKey(naverMapsClientId)}
- Naver Maps Client Secret: ${_maskApiKey(naverMapsClientSecret)}
- Is Configured: $isConfigured
''';
  }

  static String _maskApiKey(String key) {
    if (key.length <= 8) return '***';
    return '${key.substring(0, 4)}***${key.substring(key.length - 4)}';
  }
}

// 지도 서비스 타입 열거형
enum MapServiceType {
  google,
  naver,
}

// 지도 설정 클래스
class MapSettings {
  final MapServiceType preferredService;
  final bool autoSelectByLocation;
  final double defaultZoom;
  final bool showMyLocation;
  final bool enableMyLocationButton;

  const MapSettings({
    this.preferredService = MapServiceType.google,
    this.autoSelectByLocation = true,
    this.defaultZoom = 15.0,
    this.showMyLocation = true,
    this.enableMyLocationButton = true,
  });

  MapSettings copyWith({
    MapServiceType? preferredService,
    bool? autoSelectByLocation,
    double? defaultZoom,
    bool? showMyLocation,
    bool? enableMyLocationButton,
  }) {
    return MapSettings(
      preferredService: preferredService ?? this.preferredService,
      autoSelectByLocation: autoSelectByLocation ?? this.autoSelectByLocation,
      defaultZoom: defaultZoom ?? this.defaultZoom,
      showMyLocation: showMyLocation ?? this.showMyLocation,
      enableMyLocationButton: enableMyLocationButton ?? this.enableMyLocationButton,
    );
  }
}