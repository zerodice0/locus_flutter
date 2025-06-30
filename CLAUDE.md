# Locus - 위치 기반 장소 저장 및 추천 앱 개발 가이드

## 중요 규칙
- **모든 Claude 응답은 한글로 작성해주세요**
- 코드 주석과 변수명은 영어로 작성하되, 설명은 한글로 해주세요
- 기술적 설명이나 가이드는 반드시 한글로 작성해주세요

## 프로젝트 개요

**앱 이름: Locus** (라틴어로 "장소"를 의미)

사용자가 가고 싶은 장소들을 지도에 저장하고, 현재 위치 기준으로 근처에 있는 장소들을 Tinder 스타일로 스와이프하여 최종 목적지를 결정하는 Flutter 앱입니다.

### 앱 이름 선정 이유
- **Locus**: 라틴어로 "장소"를 의미
- **글로벌 확장성**: 영어권 및 다국어 지원에 적합
- **독창성**: 일반적이지 않은 단어로 브랜드 구별성 확보
- **발음 용이성**: 전 세계 어디서든 쉽게 발음 가능 (로쿠스)
- **의미 명확성**: 앱의 핵심 기능인 "장소 관리"와 완벽히 일치

### 핵심 기능
- 지도에서 장소 선택 및 정보 저장
- 카테고리별 장소 분류 (음식점, 카페, 상점, 관광지 등)
- 운영시간 및 이벤트 기간 설정
- 현재 위치 기준 근처 장소 검색 (적응형 반경)
- 카드/리스트 스와이프를 통한 장소 선택
- 로컬 데이터베이스 기반 (1단계)

## 개발 환경 및 기술 스택

### 프레임워크 및 언어
- **Flutter** (Dart)
- **상태관리**: Riverpod
- **아키텍처**: Clean Architecture + MVVM
- **로컬 데이터베이스**: SQLite (sqflite 또는 drift 패키지)

### 지도 SDK 전략
- **투트랙 전략**: Naver Maps (국내) + Google Maps (해외)
- **자동 선택**: 현재 위치 기반 지도 서비스 자동 전환
- **수동 선택**: 사용자가 설정에서 선호 지도 선택 가능
- **완전 추상화**: MapService 인터페이스로 지도 종류에 관계없이 동일한 기능 제공

### 주요 패키지
```yaml
dependencies:
  flutter_riverpod: ^2.4.9
  flutter_naver_map: ^1.2.2      # 국내용
  google_maps_flutter: ^2.5.0    # 해외용
  geolocator: ^10.1.0
  permission_handler: ^11.1.0
  geocoding: ^3.0.0               # 주소 변환
  sqflite: ^2.3.0  # 또는 drift
  json_annotation: ^4.8.1
  freezed_annotation: ^2.4.1
  go_router: ^12.1.3
  
dev_dependencies:
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
  freezed: ^2.4.6
```

## 프로젝트 구조 (Clean Architecture)

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart          # Locus 앱 상수
│   │   ├── database_constants.dart
│   │   └── map_constants.dart
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── utils/
│   │   ├── location_utils.dart
│   │   ├── distance_calculator.dart
│   │   └── time_utils.dart
│   ├── database/
│   │   ├── database_helper.dart
│   │   └── tables/
│   └── services/
│       ├── map/
│       │   ├── map_service.dart        # 추상 인터페이스
│       │   ├── naver_map_service.dart  # Naver 구현체
│       │   ├── google_map_service.dart # Google 구현체
│       │   ├── map_service_factory.dart
│       │   └── map_provider_service.dart
│       └── location/
│           ├── location_service.dart
│           └── geocoding_service.dart
├── features/
│   ├── place_management/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── place_local_datasource.dart
│   │   │   │   └── category_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── place_model.dart
│   │   │   │   └── category_model.dart
│   │   │   └── repositories/
│   │   │       └── place_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── place.dart
│   │   │   │   ├── category.dart
│   │   │   │   ├── operating_hours.dart
│   │   │   │   └── event_period.dart
│   │   │   ├── repositories/
│   │   │   │   └── place_repository.dart
│   │   │   └── usecases/
│   │   │       ├── add_place.dart
│   │   │       ├── get_places.dart
│   │   │       ├── update_place.dart
│   │   │       ├── delete_place.dart
│   │   │       └── detect_duplicate_places.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── map_page.dart
│   │       │   ├── place_input_page.dart
│   │       │   ├── place_list_page.dart
│   │       │   └── place_detail_page.dart
│   │       ├── widgets/
│   │       │   ├── place_card.dart
│   │       │   ├── category_selector.dart
│   │       │   ├── operating_hours_picker.dart
│   │       │   └── duplicate_warning_dialog.dart
│   │       └── providers/
│   │           ├── place_provider.dart
│   │           ├── category_provider.dart
│   │           └── place_form_provider.dart
│   ├── place_discovery/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── search_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── search_settings_model.dart
│   │   │   └── repositories/
│   │   │       └── search_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── search_settings.dart
│   │   │   │   ├── place_with_distance.dart
│   │   │   │   └── swipe_action.dart
│   │   │   ├── repositories/
│   │   │   │   └── search_repository.dart
│   │   │   └── usecases/
│   │   │       ├── search_nearby_places.dart
│   │   │       ├── calculate_distance.dart
│   │   │       └── record_swipe_action.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── search_settings_page.dart
│   │       │   ├── card_swipe_page.dart
│   │       │   ├── list_swipe_page.dart
│   │       │   └── selection_result_page.dart
│   │       ├── widgets/
│   │       │   ├── swipeable_card.dart
│   │       │   ├── swipeable_list_item.dart
│   │       │   ├── radius_slider.dart
│   │       │   └── category_filter.dart
│   │       └── providers/
│   │           ├── search_provider.dart
│   │           ├── swipe_provider.dart
│   │           └── discovery_provider.dart
│   ├── settings/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── settings_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── user_preferences_model.dart
│   │   │   └── repositories/
│   │   │       └── settings_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_preferences.dart
│   │   │   ├── repositories/
│   │   │   │   └── settings_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_user_preferences.dart
│   │   │       ├── update_preferences.dart
│   │   │       └── export_import_data.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── settings_page.dart
│   │       │   ├── category_management_page.dart
│   │       │   └── data_management_page.dart
│   │       ├── widgets/
│   │       │   ├── settings_tile.dart
│   │       │   └── category_management_widget.dart
│   │       └── providers/
│   │           └── settings_provider.dart
│   └── common/
│       ├── presentation/
│       │   ├── pages/
│       │   │   ├── main_dashboard.dart
│       │   │   ├── onboarding_page.dart
│       │   │   └── permission_page.dart
│       │   ├── widgets/
│       │   │   ├── custom_app_bar.dart
│       │   │   ├── loading_widget.dart
│       │   │   ├── error_widget.dart
│       │   │   └── empty_state_widget.dart
│       │   └── providers/
│       │       ├── location_provider.dart
│       │       └── permission_provider.dart
└── main.dart
```

## 필요한 화면 목록

### 1. 공통/시스템 화면
- **온보딩 화면**: 앱 소개 및 주요 기능 설명
- **권한 요청 화면**: 위치 권한 요청 및 설명
- **메인 대시보드**: 주요 기능 접근점 (장소 추가, 탐색, 관리, 설정)

### 2. 장소 관리 기능
- **지도 화면**: Google Maps 기반 장소 선택
- **장소 정보 입력 화면**: 이름, 설명, 카테고리, 운영시간 등 입력
- **중복 경고 화면**: 비슷한 위치의 기존 장소 알림
- **장소 목록 화면**: 저장된 장소들의 리스트 및 관리
- **장소 상세 화면**: 개별 장소의 상세 정보 및 편집

### 3. 장소 탐색 기능
- **탐색 설정 화면**: 반경, 카테고리, 운영시간 필터 설정
- **카드 스와이프 화면**: Tinder 스타일 장소 선택 (3개 이상일 때)
- **리스트 스와이프 화면**: 세로 리스트 형태 장소 선택 (1-2개일 때)
- **선택 결과 화면**: 최종 선택된 장소 표시 및 네비게이션 연결
- **빈 상태 화면**: 근처에 저장된 장소가 없을 때

### 4. 설정 및 관리
- **앱 설정 화면**: 기본 반경, 자동 삭제, 지도 서비스 선택 등 환경설정
- **카테고리 관리 화면**: 사용자 정의 카테고리 추가/수정/삭제
- **데이터 관리 화면**: 데이터 내보내기/가져오기, 전체 삭제
- **지도 설정 화면**: 지도 서비스 선택 (자동/Naver/Google) 및 테마 설정

## 개발 진행 단계

### Phase 1: 기본 구조 설정 (1-2주)
1. Flutter 프로젝트 생성 (프로젝트명: locus)
2. Clean Architecture 폴더 구조 생성
3. 기본 라우팅 설정 (go_router)
4. Locus 브랜드 테마 및 공통 위젯 설정
5. 앱 아이콘 및 스플래시 스크린 (핀/지도 모티브)

### Phase 2: 데이터 레이어 구현 (1-2주)
1. SQLite 데이터베이스 스키마 설계
2. Entity 및 Model 클래스 생성 (freezed 사용)
3. Local DataSource 구현
4. Repository 구현
5. 기본 CRUD UseCase 구현

### Phase 3: 장소 관리 기능 (2-3주)
1. 위치 권한 및 GPS 기능 구현
2. 투트랙 지도 시스템 구현 (Naver + Google Maps)
3. 지역 기반 자동 지도 선택 로직
4. 장소 정보 입력 화면 구현
5. 장소 목록 및 상세 화면 구현
6. 중복 감지 로직 구현 (지도별 geocoding)

### Phase 4: 장소 탐색 기능 (2-3주)
1. 거리 계산 및 필터링 로직 구현
2. 탐색 설정 화면 구현
3. 카드 스와이프 화면 구현 (애니메이션 포함)
4. 리스트 스와이프 화면 구현
5. 선택 결과 및 네비게이션 연결

### Phase 5: 설정 및 완성도 (1-2주)
1. 앱 설정 화면 구현
2. 카테고리 관리 기능 구현
3. 데이터 내보내기/가져오기 기능
4. 자동 삭제 및 알림 기능
5. 전체 테스트 및 버그 수정

### Phase 6: 최적화 및 배포 준비 (1주)
1. 성능 최적화
2. 애니메이션 및 UX 개선
3. Locus 브랜드 아이덴티티 완성 (아이콘, 컬러, 폰트)
4. 다국어 지원 기반 구축 (영어, 한국어)
5. 배포 준비 (Android/iOS)

## 주요 기술적 고려사항

### 1. 지도 SDK 추상화 (투트랙)
```dart
// 통합 좌표 시스템
class UniversalLatLng {
  final double latitude;
  final double longitude;
  
  // Naver Maps로 변환
  NLatLng toNaverLatLng() => NLatLng(latitude, longitude);
  
  // Google Maps로 변환  
  LatLng toGoogleLatLng() => LatLng(latitude, longitude);
}

// 지도 서비스 추상화
abstract class MapService {
  Future<UniversalLatLng?> selectLocation();
  Future<String> getAddressFromCoordinates(double lat, double lng);
  Future<void> showMarkers(List<Place> places);
  Future<void> moveCamera(UniversalLatLng position, double zoom);
}

// 지도 타입 열거형
enum MapProvider { naver, google }

// 지역 기반 지도 선택 서비스
class MapProviderService {
  MapProvider getOptimalProvider(double lat, double lng) {
    // 한국 영역 체크 (대략적인 범위)
    if (lat >= 33.0 && lat <= 38.9 && lng >= 124.0 && lng <= 132.0) {
      return MapProvider.naver;
    }
    return MapProvider.google;
  }
}

// 구현체들
class NaverMapService implements MapService { /* 구현 */ }
class GoogleMapService implements MapService { /* 구현 */ }

// 팩토리 패턴으로 서비스 선택
class MapServiceFactory {
  static MapService create(MapProvider provider) {
    switch (provider) {
      case MapProvider.naver:
        return NaverMapService();
      case MapProvider.google:
        return GoogleMapService();
    }
  }
}
```

### 2. 거리 계산 최적화
- Haversine 공식 사용
- 대량 데이터 처리 시 Isolate 활용

### 3. 상태 관리 전략
- Riverpod Provider 패턴 활용
- 로컬 상태와 전역 상태 구분
- 에러 상태 및 로딩 상태 관리

### 4. 데이터베이스 마이그레이션
- 버전 관리를 통한 스키마 변경 대응
- 데이터 백업 및 복구 기능

## 브랜딩 가이드라인

### Locus 브랜드 아이덴티티
- **로고**: 지도 핀 모티브 + "L" 이니셜 조합
- **컬러 팔레트**: 
  - Primary: 지도를 연상시키는 블루/그린 계열
  - Secondary: 따뜻한 오렌지 (선택된 장소 강조용)
- **타이포그래피**: 모던하고 읽기 쉬운 sans-serif 폰트
- **태그라인**: "Your Place Library" (영어) / "당신의 장소 라이브러리" (한국어)

### 다국어 확장 계획
- **1단계**: 한국어 (기본), 영어
- **2단계**: 일본어, 중국어 (동아시아 진출)
- **3단계**: 스페인어, 프랑스어 (글로벌 확장)

## 확장 계획 (2단계)

### 클라우드 연동 준비사항
1. Repository 인터페이스 확장
2. Remote DataSource 추가
3. 동기화 로직 구현
4. 오프라인 모드 지원

### Naver Maps 고도화
1. 실내 지도 기능 활용
2. 한국어 주소 체계 최적화
3. 대중교통 연동 기능
4. 네이버 플레이스 API 연동 (선택사항)

## 참고사항

- **프로젝트명**: locus (소문자, Flutter 프로젝트 네이밍 규칙)
- **앱 표시명**: Locus
- **패키지명**: com.locus.app (Android), com.locus.app (iOS)
- **코드 품질**: Dart 린트 규칙 준수, 테스트 코드 작성
- **성능**: 메모리 누수 방지, 이미지 최적화
- **접근성**: 시각 장애인 지원, 폰트 크기 대응
- **다국어**: 향후 글로벌 서비스 대비 internationalization 설정

이 가이드를 기반으로 단계별로 Locus 앱 개발을 진행하세요. 각 단계에서 막히는 부분이 있으면 언제든 문의해주세요.