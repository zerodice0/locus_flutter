class AppConstants {
  static const String appName = 'Locus';
  static const String appTagline = 'Your Place Library';
  static const String appTaglineKo = '당신의 장소 라이브러리';
  
  // Version
  static const String appVersion = '1.0.0';
  
  // Default values
  static const double defaultSearchRadius = 2.0; // km
  static const int maxPlacesPerSearch = 50;
  static const int maxRecentSearches = 10;
  
  // Database
  static const String databaseName = 'locus.db';
  static const int databaseVersion = 1;
  
  // Preferences keys
  static const String prefKeyMapProvider = 'map_provider';
  static const String prefKeyDefaultRadius = 'default_radius';
  static const String prefKeyAutoDelete = 'auto_delete';
  static const String prefKeyLanguage = 'language';
  
  // Map constants
  static const double koreaLatMin = 33.0;
  static const double koreaLatMax = 38.9;
  static const double koreaLngMin = 124.0;
  static const double koreaLngMax = 132.0;
  
  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 300);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
}