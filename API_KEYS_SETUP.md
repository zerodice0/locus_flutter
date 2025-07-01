# API 키 설정 가이드

이 프로젝트는 Google Maps와 Naver Maps API를 사용합니다. 앱을 실행하기 전에 API 키를 설정해야 합니다.

## 🔐 보안 중요사항

- **절대로 API 키를 소스코드에 직접 입력하지 마세요**
- **API 키는 .env 파일과 환경변수를 통해서만 관리합니다**
- **.env 파일은 Git에 커밋되지 않도록 .gitignore에 포함되어 있습니다**

## 📝 설정 단계

### 1. .env 파일 생성

프로젝트 루트에 `.env` 파일을 생성하고 다음 내용을 입력하세요:

```env
# Google Maps API Key (필수)
GOOGLE_MAPS_API_KEY=여기에_구글_맵스_API_키_입력

# Naver Maps API Keys (필수)
NAVER_MAPS_CLIENT_ID=여기에_네이버_맵스_클라이언트_ID_입력
NAVER_MAPS_CLIENT_SECRET=여기에_네이버_맵스_클라이언트_시크릿_입력
```

### 2. API 키 발급

#### Google Maps API
1. [Google Cloud Console](https://console.cloud.google.com/) 접속
2. 프로젝트 생성 또는 선택
3. **API 및 서비스 > 라이브러리**에서 다음 API 활성화:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API
   - Geocoding API
4. **API 및 서비스 > 사용자 인증 정보**에서 API 키 생성
5. API 키 제한 설정 (보안상 중요!)

#### Naver Maps API
1. [네이버 클라우드 플랫폼](https://www.ncloud.com/) 접속
2. **콘솔 > AI·Application Service > Maps**
3. Application 등록
4. Client ID와 Client Secret 발급

### 3. 환경변수 설정 (선택사항)

시스템 환경변수로도 설정할 수 있습니다:

```bash
# macOS/Linux
export GOOGLE_MAPS_API_KEY="your_google_maps_api_key"
export NAVER_MAPS_CLIENT_ID="your_naver_maps_client_id"
export NAVER_MAPS_CLIENT_SECRET="your_naver_maps_client_secret"

# Windows
set GOOGLE_MAPS_API_KEY=your_google_maps_api_key
set NAVER_MAPS_CLIENT_ID=your_naver_maps_client_id
set NAVER_MAPS_CLIENT_SECRET=your_naver_maps_client_secret
```

## 🚀 실행 방법

### 개발 시 (Flutter)
```bash
# 의존성 설치
flutter pub get

# 앱 실행
flutter run
```

### Android 빌드 시
```bash
# 환경변수와 함께 빌드
GOOGLE_MAPS_API_KEY="your_key" NAVER_MAPS_CLIENT_ID="your_id" flutter build apk
```

### iOS 빌드 시
Xcode에서 Build Settings에 User-Defined Settings 추가:
- `GOOGLE_MAPS_API_KEY` = `your_key`
- `NAVER_MAPS_CLIENT_ID` = `your_id`

## ⚠️ 문제 해결

### API 키를 찾을 수 없다는 오류가 나는 경우
1. `.env` 파일이 프로젝트 루트에 있는지 확인
2. API 키가 올바르게 입력되었는지 확인
3. `flutter clean` 후 `flutter pub get` 재실행

### 지도가 표시되지 않는 경우
1. API 키가 유효한지 확인
2. Google Cloud Console에서 해당 API가 활성화되었는지 확인
3. 네이버 클라우드 플랫폼에서 애플리케이션이 등록되었는지 확인
4. 실제 디바이스에서 테스트 (에뮬레이터에서는 지도가 제대로 표시되지 않을 수 있음)

## 📋 체크리스트

- [ ] `.env` 파일 생성 및 API 키 입력
- [ ] Google Maps API 키 발급 및 API 활성화
- [ ] Naver Maps Client ID/Secret 발급
- [ ] API 키 제한 설정 (보안)
- [ ] `flutter pub get` 실행
- [ ] 실제 디바이스에서 테스트

## 🔒 보안 모범 사례

1. **API 키 제한 설정**: Google Cloud Console에서 애플리케이션 제한 및 API 제한 설정
2. **사용량 모니터링**: API 사용량을 정기적으로 확인
3. **키 로테이션**: 정기적으로 API 키 갱신
4. **Git 관리**: .env 파일이 절대 Git에 커밋되지 않도록 주의

## 📞 지원

API 키 설정에 문제가 있으면 다음을 확인하세요:
- [Google Maps Platform 문서](https://developers.google.com/maps/documentation)
- [네이버 지도 API 문서](https://navermaps.github.io/android-map-sdk/guide-ko/)