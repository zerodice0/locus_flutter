import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';

// Geocoding Service Provider
final geocodingServiceProvider = Provider<GeocodingService>((ref) {
  return GeocodingServiceImpl();
});

abstract class GeocodingService {
  Future<String?> getAddressFromCoordinates(double latitude, double longitude);
  Future<List<Location>> getCoordinatesFromAddress(String address);
  Future<List<Placemark>> getPlacemarksFromCoordinates(double latitude, double longitude);
}

class GeocodingServiceImpl implements GeocodingService {
  @override
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isEmpty) return null;
      
      final placemark = placemarks.first;
      
      // 한국 주소 형식으로 구성
      final addressComponents = <String>[];
      
      // 국가가 한국인 경우
      if (placemark.isoCountryCode == 'KR') {
        // 한국 주소: 시/도 + 시/군/구 + 동/읍/면 + 상세주소
        if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
          addressComponents.add(placemark.administrativeArea!);
        }
        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          addressComponents.add(placemark.locality!);
        }
        if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
          addressComponents.add(placemark.subLocality!);
        }
        if (placemark.thoroughfare != null && placemark.thoroughfare!.isNotEmpty) {
          addressComponents.add(placemark.thoroughfare!);
        }
        if (placemark.subThoroughfare != null && placemark.subThoroughfare!.isNotEmpty) {
          addressComponents.add(placemark.subThoroughfare!);
        }
      } else {
        // 해외 주소: 서구식 주소 형식
        if (placemark.subThoroughfare != null && placemark.subThoroughfare!.isNotEmpty) {
          addressComponents.add(placemark.subThoroughfare!);
        }
        if (placemark.thoroughfare != null && placemark.thoroughfare!.isNotEmpty) {
          addressComponents.add(placemark.thoroughfare!);
        }
        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          addressComponents.add(placemark.locality!);
        }
        if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
          addressComponents.add(placemark.administrativeArea!);
        }
        if (placemark.country != null && placemark.country!.isNotEmpty) {
          addressComponents.add(placemark.country!);
        }
      }
      
      return addressComponents.join(' ');
    } catch (e) {
      throw GeocodingException('Failed to get address from coordinates: $e');
    }
  }

  @override
  Future<List<Location>> getCoordinatesFromAddress(String address) async {
    if (address.trim().isEmpty) {
      throw ArgumentError('Address cannot be empty');
    }
    
    try {
      return await locationFromAddress(address);
    } catch (e) {
      throw GeocodingException('Failed to get coordinates from address: $e');
    }
  }

  @override
  Future<List<Placemark>> getPlacemarksFromCoordinates(double latitude, double longitude) async {
    try {
      return await placemarkFromCoordinates(latitude, longitude);
    } catch (e) {
      throw GeocodingException('Failed to get placemarks from coordinates: $e');
    }
  }

  // 주소를 짧은 형태로 변환 (예: "서울특별시 강남구 역삼동" -> "강남구 역삼동")
  String getShortAddress(String fullAddress) {
    if (fullAddress.isEmpty) return fullAddress;
    
    // 한국 주소에서 시/도 부분 제거
    final koreanProvinces = [
      '서울특별시', '부산광역시', '대구광역시', '인천광역시', '광주광역시', 
      '대전광역시', '울산광역시', '세종특별자치시', '경기도', '강원도', 
      '충청북도', '충청남도', '전라북도', '전라남도', '경상북도', '경상남도', 
      '제주특별자치도'
    ];
    
    for (final province in koreanProvinces) {
      if (fullAddress.startsWith(province)) {
        return fullAddress.substring(province.length).trim();
      }
    }
    
    return fullAddress;
  }

  // 주소에서 구/시/군만 추출
  String? getDistrictFromAddress(String address) {
    final parts = address.split(' ');
    
    for (final part in parts) {
      if (part.endsWith('구') || part.endsWith('시') || part.endsWith('군')) {
        return part;
      }
    }
    
    return null;
  }

  // 주소가 유효한지 검증
  Future<bool> isValidAddress(String address) async {
    try {
      final locations = await getCoordinatesFromAddress(address);
      return locations.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // 두 주소가 같은 지역인지 확인 (구/시/군 레벨)
  bool isSameDistrict(String address1, String address2) {
    final district1 = getDistrictFromAddress(address1);
    final district2 = getDistrictFromAddress(address2);
    
    if (district1 == null || district2 == null) return false;
    
    return district1 == district2;
  }
}

class GeocodingException implements Exception {
  final String message;
  GeocodingException(this.message);
  
  @override
  String toString() => 'GeocodingException: $message';
}