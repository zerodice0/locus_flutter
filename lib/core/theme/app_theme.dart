import 'package:flutter/material.dart';

class AppTheme {
  // Primary colors - Deep Navigation Blue (지도/네비게이션 연상)
  static const Color primaryBlue = Color(0xFF1E3A8A); // Deep blue
  static const Color primaryLightBlue = Color(0xFF3B82F6); // Bright blue
  static const Color primaryDarkBlue = Color(0xFF1E40AF); // Dark blue
  
  // Secondary colors - Discovery Orange (발견/탐험의 즐거움)
  static const Color secondaryOrange = Color(0xFFEA580C); // Vibrant orange
  static const Color secondaryLightOrange = Color(0xFFF97316); // Light orange
  static const Color secondaryDarkOrange = Color(0xFFC2410C); // Dark orange
  
  // Accent colors - Personal Purple (개인화/특별함)
  static const Color accentPurple = Color(0xFF7C3AED); // Purple
  static const Color accentLightPurple = Color(0xFF8B5CF6); // Light purple
  static const Color accentDarkPurple = Color(0xFF6D28D9); // Dark purple
  
  // Neutral colors - Clean & Modern
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slightly blue-tinted white
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF1F5F9); // Light blue-gray
  static const Color onSurfaceLight = Color(0xFF0F172A); // Deep slate
  static const Color onSurfaceSecondary = Color(0xFF475569); // Medium slate
  
  // Status colors
  static const Color errorRed = Color(0xFFDC2626); // Modern red
  static const Color successGreen = Color(0xFF059669); // Emerald green
  static const Color warningAmber = Color(0xFFD97706); // Amber
  static const Color infoBlue = Color(0xFF0EA5E9); // Sky blue
  
  // Map-specific colors
  static const Color mapMarkerPrimary = primaryBlue;
  static const Color mapMarkerSelected = secondaryOrange;
  static const Color mapMarkerUser = accentPurple;
  
  // Category colors (더 다양하고 구분되는 색상)
  static const List<Color> categoryColors = [
    Color(0xFFEF4444), // Red - 음식점
    Color(0xFFF59E0B), // Amber - 카페
    Color(0xFF10B981), // Emerald - 쇼핑
    Color(0xFF3B82F6), // Blue - 엔터테인먼트
    Color(0xFF8B5CF6), // Violet - 병원/헬스케어
    Color(0xFFEC4899), // Pink - 뷰티/스파
    Color(0xFF06B6D4), // Cyan - 스포츠/레저
    Color(0xFF84CC16), // Lime - 자연/공원
    Color(0xFFF97316), // Orange - 교통
    Color(0xFF6366F1), // Indigo - 교육
  ];
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
        primary: primaryBlue,
        secondary: secondaryOrange,
        tertiary: accentPurple,
        surface: surfaceLight,
        surfaceContainerHighest: surfaceSecondary,
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onSurface: onSurfaceLight,
        onError: Colors.white,
      ),
      
      // AppBar theme - 그라데이션 효과 추가
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        shadowColor: primaryBlue.withValues(alpha: 0.3),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 24,
        ),
      ),
      
      // Card theme - 더 현대적이고 깔끔한 디자인
      cardTheme: CardTheme(
        elevation: 3,
        shadowColor: primaryBlue.withValues(alpha: 0.08),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        color: surfaceLight,
      ),
      
      // Elevated button theme - 더 매력적인 그라데이션 느낌
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: primaryBlue.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 14,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Outlined button theme - 섬세한 테두리 효과
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: BorderSide(color: primaryBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 14,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),
      
      // FloatingActionButton theme - 역동적인 오렌지
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: secondaryOrange,
        foregroundColor: Colors.white,
        elevation: 6,
        focusElevation: 8,
        hoverElevation: 8,
        highlightElevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      
      // Input decoration theme - 현대적이고 깔끔한 입력 필드
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: onSurfaceSecondary.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: onSurfaceSecondary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        hintStyle: TextStyle(
          color: onSurfaceSecondary.withValues(alpha: 0.7),
          fontSize: 15,
        ),
      ),
      
      // List tile theme - 더 매력적인 리스트 아이템
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        iconColor: primaryBlue,
        textColor: onSurfaceLight,
      ),
      
      // Chip theme - 다채로운 칩 디자인
      chipTheme: ChipThemeData(
        backgroundColor: surfaceSecondary,
        selectedColor: primaryLightBlue.withValues(alpha: 0.2),
        secondarySelectedColor: secondaryLightOrange.withValues(alpha: 0.2),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      
      // Bottom navigation bar theme - 현대적인 네비게이션
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceLight,
        selectedItemColor: primaryBlue,
        unselectedItemColor: onSurfaceSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Icon theme
      iconTheme: const IconThemeData(
        color: primaryBlue,
        size: 24,
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: onSurfaceSecondary.withValues(alpha: 0.2),
        thickness: 1,
        space: 1,
      ),
      
      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryBlue,
        linearTrackColor: surfaceSecondary,
        circularTrackColor: surfaceSecondary,
      ),
      
      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryBlue;
          }
          return onSurfaceSecondary.withValues(alpha: 0.6);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryLightBlue.withValues(alpha: 0.3);
          }
          return surfaceSecondary;
        }),
      ),
    );
  }
  
  // Text styles - 모던하고 읽기 쉬운 타이포그래피
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: onSurfaceLight,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: onSurfaceLight,
    letterSpacing: -0.3,
    height: 1.3,
  );
  
  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: onSurfaceLight,
    letterSpacing: 0.15,
    height: 1.4,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: onSurfaceLight,
    letterSpacing: 0.15,
    height: 1.5,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: onSurfaceLight,
    letterSpacing: 0.1,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: onSurfaceLight,
    letterSpacing: 0.1,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: onSurfaceSecondary,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: onSurfaceLight,
    letterSpacing: 0.3,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: onSurfaceLight,
    letterSpacing: 0.3,
  );
  
  // 추가적인 특수 텍스트 스타일들
  static const TextStyle captionText = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: onSurfaceSecondary,
    letterSpacing: 0.4,
  );
  
  static const TextStyle buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
  );
  
  // Locus 브랜드 전용 스타일
  static const TextStyle brandTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: primaryBlue,
    letterSpacing: 1.2,
  );
  
  static const TextStyle brandSubtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: onSurfaceSecondary,
    letterSpacing: 0.5,
  );
  
  // 색상별 헬퍼 메서드들
  static Color getCategoryColor(int index) {
    return categoryColors[index % categoryColors.length];
  }
  
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return successGreen;
      case 'error':
        return errorRed;
      case 'warning':
        return warningAmber;
      case 'info':
        return infoBlue;
      default:
        return primaryBlue;
    }
  }
  
  // 그라데이션 정의
  static const Gradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryLightBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const Gradient accentGradient = LinearGradient(
    colors: [secondaryOrange, secondaryLightOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const Gradient purpleGradient = LinearGradient(
    colors: [accentPurple, accentLightPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}