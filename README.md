# Locus

**위치 기반 장소 저장 및 추천 앱**

Locus는 사용자가 가고 싶은 장소들을 지도에 저장하고, 현재 위치 기준으로 근처에 있는 장소들을 Tinder 스타일로 스와이프하여 최종 목적지를 결정하는 Flutter 앱입니다.

## 📍 주요 기능

- **장소 저장**: 지도에서 장소 선택 및 정보 저장
- **카테고리 분류**: 음식점, 카페, 상점, 관광지 등 카테고리별 관리
- **운영시간 설정**: 장소별 운영시간 및 이벤트 기간 설정
- **스마트 탐색**: 현재 위치 기준 근처 장소 검색 (적응형 반경)
- **스와이프 선택**: 카드/리스트 스와이프를 통한 직관적인 장소 선택
- **투트랙 지도**: Naver Maps (국내) + Google Maps (해외) 자동 전환

## 🛠 기술 스택

### 프레임워크 & 언어
- **Flutter** (Dart)
- **상태관리**: Riverpod
- **아키텍처**: Clean Architecture + MVVM

### 핵심 라이브러리
```yaml
dependencies:
  flutter_riverpod: ^2.4.9          # 상태관리
  flutter_naver_map: ^1.2.2         # 국내 지도
  google_maps_flutter: ^2.5.0       # 해외 지도
  geolocator: ^10.1.0               # 위치 서비스
  geocoding: ^3.0.0                 # 주소 변환
  sqflite: ^2.3.0                   # 로컬 데이터베이스
  go_router: ^12.1.3                # 라우팅
  freezed: ^2.4.6                   # 불변 객체
  json_annotation: ^4.8.1           # JSON 직렬화
```

## 📁 프로젝트 구조

```
lib/
├── core/                           # 공통 기능
│   ├── constants/                  # 상수 정의
│   ├── errors/                     # 에러 처리
│   ├── utils/                      # 유틸리티 함수
│   ├── database/                   # 데이터베이스 설정
│   └── services/                   # 외부 서비스 연동
│       ├── map/                    # 지도 서비스 추상화
│       └── location/               # 위치 서비스
├── features/                       # 기능별 모듈
│   ├── place_management/           # 장소 관리
│   │   ├── data/                   # 데이터 레이어
│   │   ├── domain/                 # 비즈니스 로직
│   │   └── presentation/           # UI 레이어
│   ├── place_discovery/            # 장소 탐색
│   ├── settings/                   # 설정 관리
│   └── common/                     # 공통 UI 컴포넌트
└── main.dart                       # 앱 진입점
```

## 🎯 개발 로드맵

### Phase 1: 기본 구조 설정 (1-2주)
- [x] Flutter 프로젝트 생성
- [x] Clean Architecture 폴더 구조 생성
- [ ] 기본 라우팅 설정 (go_router)
- [ ] Locus 브랜드 테마 및 공통 위젯 설정
- [ ] 앱 아이콘 및 스플래시 스크린

### Phase 2: 데이터 레이어 구현 (1-2주)
- [ ] SQLite 데이터베이스 스키마 설계
- [ ] Entity 및 Model 클래스 생성 (freezed 사용)
- [ ] Local DataSource 구현
- [ ] Repository 구현
- [ ] 기본 CRUD UseCase 구현

### Phase 3: 장소 관리 기능 (2-3주)
- [ ] 위치 권한 및 GPS 기능 구현
- [ ] 투트랙 지도 시스템 구현 (Naver + Google Maps)
- [ ] 지역 기반 자동 지도 선택 로직
- [ ] 장소 정보 입력 화면 구현
- [ ] 장소 목록 및 상세 화면 구현
- [ ] 중복 감지 로직 구현

### Phase 4: 장소 탐색 기능 (2-3주)
- [ ] 거리 계산 및 필터링 로직 구현
- [ ] 탐색 설정 화면 구현
- [ ] 카드 스와이프 화면 구현 (애니메이션 포함)
- [ ] 리스트 스와이프 화면 구현
- [ ] 선택 결과 및 네비게이션 연결

### Phase 5: 설정 및 완성도 (1-2주)
- [ ] 앱 설정 화면 구현
- [ ] 카테고리 관리 기능 구현
- [ ] 데이터 내보내기/가져오기 기능
- [ ] 자동 삭제 및 알림 기능
- [ ] 전체 테스트 및 버그 수정

### Phase 6: 최적화 및 배포 준비 (1주)
- [ ] 성능 최적화
- [ ] 애니메이션 및 UX 개선
- [ ] Locus 브랜드 아이덴티티 완성
- [ ] 다국어 지원 기반 구축 (영어, 한국어)
- [ ] 배포 준비 (Android/iOS)

## 🗺 지도 SDK 전략

### 투트랙 시스템
- **Naver Maps**: 한국 내 정확한 위치 정보 및 한글 주소 지원
- **Google Maps**: 해외 지역 및 글로벌 표준 지원
- **자동 전환**: 현재 위치 기반으로 최적의 지도 서비스 선택
- **완전 추상화**: MapService 인터페이스로 통일된 API 제공

### 지역 기반 자동 선택
```dart
// 한국 영역 (위도: 33.0~38.9, 경도: 124.0~132.0)
if (lat >= 33.0 && lat <= 38.9 && lng >= 124.0 && lng <= 132.0) {
  return MapProvider.naver;  // 국내 → Naver Maps
}
return MapProvider.google;   // 해외 → Google Maps
```

## 🚀 시작하기

### 사전 요구사항
- Flutter SDK 3.16.0 이상
- Dart SDK 3.2.0 이상
- Android Studio / VS Code
- Android SDK (Android 개발용)
- Xcode (iOS 개발용, macOS에서만)

### 설치 및 실행
```bash
# 저장소 클론
git clone https://github.com/yourusername/locus_flutter.git
cd locus_flutter

# 의존성 설치
flutter pub get

# 코드 생성 (필요시)
flutter packages pub run build_runner build

# 앱 실행
flutter run
```

### API 키 설정
1. `android/app/google-services.json` (Google Maps용)
2. `ios/Runner/GoogleService-Info.plist` (Google Maps용)
3. Naver Maps API 키 설정

> ⚠️ **보안 주의**: API 키 파일들은 `.gitignore`에 포함되어 있습니다. 실제 키는 별도로 설정해주세요.

## 🎨 브랜드 아이덴티티

### Locus 브랜딩
- **의미**: 라틴어로 "장소"를 의미
- **컨셉**: 사용자의 개인적인 장소 라이브러리
- **태그라인**: "Your Place Library" / "당신의 장소 라이브러리"

### 디자인 컨셉
- **로고**: 지도 핀 + "L" 이니셜 조합
- **컬러**: 지도를 연상시키는 블루/그린 + 강조용 오렌지
- **타이포그래피**: 모던하고 읽기 쉬운 sans-serif

## 🌍 다국어 지원 계획

- **1단계**: 한국어 (기본), 영어
- **2단계**: 일본어, 중국어 (동아시아)
- **3단계**: 스페인어, 프랑스어 (글로벌)

## 📱 지원 플랫폼

- **Android**: API 21 (Android 5.0) 이상
- **iOS**: iOS 12.0 이상

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이센스

이 프로젝트는 MIT 라이센스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

## 📞 문의

프로젝트 관련 문의사항이 있으시면 이슈를 생성해주세요.

---

**Locus** - 당신만의 특별한 장소들을 기록하고 발견하세요 📍
