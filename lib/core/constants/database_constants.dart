class DatabaseConstants {
  static const String databaseName = 'locus.db';
  static const int databaseVersion = 2;

  // Table names
  static const String tablePlaces = 'places';
  static const String tableCategories = 'categories';
  static const String tableOperatingHours = 'operating_hours';
  static const String tableEventPeriods = 'event_periods';
  static const String tableSearchHistory = 'search_history';
  static const String tableSwipeActions = 'swipe_actions';

  // Places table columns
  static const String placeId = 'id';
  static const String placeName = 'name';
  static const String placeDescription = 'description';
  static const String placeLatitude = 'latitude';
  static const String placeLongitude = 'longitude';
  static const String placeAddress = 'address';
  static const String placeCategoryId = 'category_id';
  static const String placeCreatedAt = 'created_at';
  static const String placeUpdatedAt = 'updated_at';
  static const String placeIsActive = 'is_active';
  static const String placeNotes = 'notes';
  static const String placeRating = 'rating';
  static const String placeVisitCount = 'visit_count';
  static const String placeLastVisited = 'last_visited';
  static const String placeImagePath = 'image_path';

  // Categories table columns
  static const String categoryId = 'id';
  static const String categoryName = 'name';
  static const String categoryIcon = 'icon';
  static const String categoryColor = 'color';
  static const String categoryIsDefault = 'is_default';
  static const String categoryCreatedAt = 'created_at';

  // Operating hours table columns
  static const String operatingHoursId = 'id';
  static const String operatingHoursPlaceId = 'place_id';
  static const String operatingHoursDayOfWeek = 'day_of_week'; // 0-6 (Sunday-Saturday)
  static const String operatingHoursOpenTime = 'open_time'; // HH:mm format
  static const String operatingHoursCloseTime = 'close_time'; // HH:mm format
  static const String operatingHoursIsClosed = 'is_closed';

  // Event periods table columns
  static const String eventPeriodId = 'id';
  static const String eventPeriodPlaceId = 'place_id';
  static const String eventPeriodName = 'name';
  static const String eventPeriodStartDate = 'start_date';
  static const String eventPeriodEndDate = 'end_date';
  static const String eventPeriodDescription = 'description';

  // Search history table columns
  static const String searchHistoryId = 'id';
  static const String searchHistoryQuery = 'query';
  static const String searchHistoryLatitude = 'latitude';
  static const String searchHistoryLongitude = 'longitude';
  static const String searchHistoryRadius = 'radius';
  static const String searchHistoryCategoryIds = 'category_ids'; // JSON array
  static const String searchHistoryCreatedAt = 'created_at';

  // Swipe actions table columns
  static const String swipeActionId = 'id';
  static const String swipeActionPlaceId = 'place_id';
  static const String swipeActionDirection = 'direction';
  static const String swipeActionTimestamp = 'timestamp';
  static const String swipeActionSessionId = 'session_id';

  // SQL CREATE statements
  static const String createPlacesTable = '''
    CREATE TABLE $tablePlaces (
      $placeId TEXT PRIMARY KEY,
      $placeName TEXT NOT NULL,
      $placeDescription TEXT,
      $placeLatitude REAL NOT NULL,
      $placeLongitude REAL NOT NULL,
      $placeAddress TEXT,
      $placeCategoryId TEXT NOT NULL,
      $placeCreatedAt TEXT NOT NULL,
      $placeUpdatedAt TEXT NOT NULL,
      $placeIsActive INTEGER NOT NULL DEFAULT 1,
      $placeNotes TEXT,
      $placeRating REAL,
      $placeVisitCount INTEGER NOT NULL DEFAULT 0,
      $placeLastVisited TEXT,
      $placeImagePath TEXT,
      FOREIGN KEY ($placeCategoryId) REFERENCES $tableCategories ($categoryId)
    )
  ''';

  static const String createCategoriesTable = '''
    CREATE TABLE $tableCategories (
      $categoryId TEXT PRIMARY KEY,
      $categoryName TEXT NOT NULL UNIQUE,
      $categoryIcon TEXT NOT NULL,
      $categoryColor TEXT NOT NULL,
      $categoryIsDefault INTEGER NOT NULL DEFAULT 0,
      $categoryCreatedAt TEXT NOT NULL
    )
  ''';

  static const String createOperatingHoursTable = '''
    CREATE TABLE $tableOperatingHours (
      $operatingHoursId TEXT PRIMARY KEY,
      $operatingHoursPlaceId TEXT NOT NULL,
      $operatingHoursDayOfWeek INTEGER NOT NULL,
      $operatingHoursOpenTime TEXT,
      $operatingHoursCloseTime TEXT,
      $operatingHoursIsClosed INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY ($operatingHoursPlaceId) REFERENCES $tablePlaces ($placeId) ON DELETE CASCADE
    )
  ''';

  static const String createEventPeriodsTable = '''
    CREATE TABLE $tableEventPeriods (
      $eventPeriodId TEXT PRIMARY KEY,
      $eventPeriodPlaceId TEXT NOT NULL,
      $eventPeriodName TEXT NOT NULL,
      $eventPeriodStartDate TEXT NOT NULL,
      $eventPeriodEndDate TEXT NOT NULL,
      $eventPeriodDescription TEXT,
      FOREIGN KEY ($eventPeriodPlaceId) REFERENCES $tablePlaces ($placeId) ON DELETE CASCADE
    )
  ''';

  static const String createSearchHistoryTable = '''
    CREATE TABLE $tableSearchHistory (
      $searchHistoryId TEXT PRIMARY KEY,
      $searchHistoryQuery TEXT,
      $searchHistoryLatitude REAL NOT NULL,
      $searchHistoryLongitude REAL NOT NULL,
      $searchHistoryRadius REAL NOT NULL,
      $searchHistoryCategoryIds TEXT,
      $searchHistoryCreatedAt TEXT NOT NULL
    )
  ''';

  static const String createSwipeActionsTable = '''
    CREATE TABLE $tableSwipeActions (
      $swipeActionId INTEGER PRIMARY KEY AUTOINCREMENT,
      $swipeActionPlaceId TEXT NOT NULL,
      $swipeActionDirection TEXT NOT NULL,
      $swipeActionTimestamp TEXT NOT NULL,
      $swipeActionSessionId TEXT,
      FOREIGN KEY ($swipeActionPlaceId) REFERENCES $tablePlaces ($placeId) ON DELETE CASCADE
    )
  ''';

  // Indexes for better query performance
  static const String createPlaceLocationIndex = '''
    CREATE INDEX idx_place_location ON $tablePlaces ($placeLatitude, $placeLongitude)
  ''';

  static const String createPlaceCategoryIndex = '''
    CREATE INDEX idx_place_category ON $tablePlaces ($placeCategoryId)
  ''';

  static const String createOperatingHoursPlaceIndex = '''
    CREATE INDEX idx_operating_hours_place ON $tableOperatingHours ($operatingHoursPlaceId)
  ''';

  static const String createEventPeriodsPlaceIndex = '''
    CREATE INDEX idx_event_periods_place ON $tableEventPeriods ($eventPeriodPlaceId)
  ''';

  static const String createSwipeActionsPlaceIndex = '''
    CREATE INDEX idx_swipe_actions_place ON $tableSwipeActions ($swipeActionPlaceId)
  ''';

  static const String createSwipeActionsTimestampIndex = '''
    CREATE INDEX idx_swipe_actions_timestamp ON $tableSwipeActions ($swipeActionTimestamp)
  ''';

  // Default categories data
  static const List<Map<String, dynamic>> defaultCategories = [
    {
      'id': 'cat_restaurant',
      'name': '음식점',
      'icon': 'restaurant',
      'color': 'FF2196F3', // Blue
      'is_default': 1,
    },
    {
      'id': 'cat_cafe',
      'name': '카페',
      'icon': 'local_cafe',
      'color': 'FF8D6E63', // Brown
      'is_default': 1,
    },
    {
      'id': 'cat_shopping',
      'name': '쇼핑',
      'icon': 'shopping_bag',
      'color': 'FFE91E63', // Pink
      'is_default': 1,
    },
    {
      'id': 'cat_entertainment',
      'name': '엔터테인먼트',
      'icon': 'movie',
      'color': 'FF9C27B0', // Purple
      'is_default': 1,
    },
    {
      'id': 'cat_travel',
      'name': '여행/관광',
      'icon': 'place',
      'color': 'FF4CAF50', // Green
      'is_default': 1,
    },
    {
      'id': 'cat_healthcare',
      'name': '의료/건강',
      'icon': 'local_hospital',
      'color': 'FFF44336', // Red
      'is_default': 1,
    },
    {
      'id': 'cat_education',
      'name': '교육',
      'icon': 'school',
      'color': 'FF607D8B', // Blue Grey
      'is_default': 1,
    },
    {
      'id': 'cat_other',
      'name': '기타',
      'icon': 'more_horiz',
      'color': 'FF9E9E9E', // Grey
      'is_default': 1,
    },
  ];
}