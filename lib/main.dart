import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:locus_flutter/core/routes/app_router.dart';
import 'package:locus_flutter/core/theme/app_theme.dart';
import 'package:locus_flutter/core/config/map_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('Environment variables loaded successfully');
    debugPrint(MapConfig.debugInfo);
  } catch (e) {
    debugPrint('Failed to load .env file: $e');
    debugPrint('Using default API keys');
  }

  // Initialize Naver Maps
  try {
    await FlutterNaverMap().init(
      clientId: MapConfig.naverMapsClientId,
      onAuthFailed: (ex) {
        debugPrint('Naver Maps auth failed: $ex');
      },
    );
    debugPrint('Naver Maps initialized successfully');
  } catch (e) {
    debugPrint('Failed to initialize Naver Maps: $e');
  }

  runApp(const ProviderScope(child: LocusApp()));
}

class LocusApp extends StatelessWidget {
  const LocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Locus',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
