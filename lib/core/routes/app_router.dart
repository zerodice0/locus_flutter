import 'package:go_router/go_router.dart';
import 'package:locus_flutter/features/common/presentation/pages/main_dashboard.dart';
import 'package:locus_flutter/features/place_management/presentation/pages/place_list_page.dart';
import 'package:locus_flutter/features/place_management/presentation/pages/add_place_page.dart';
import 'package:locus_flutter/features/place_management/presentation/pages/place_detail_page.dart';
import 'package:locus_flutter/features/place_management/presentation/pages/edit_place_page.dart';
import 'package:locus_flutter/features/place_management/presentation/pages/map_location_picker_page.dart';
import 'package:locus_flutter/features/place_management/presentation/pages/real_map_location_picker_page.dart';
import 'package:locus_flutter/features/place_discovery/presentation/pages/place_discovery_page.dart';
import 'package:locus_flutter/features/place_discovery/presentation/pages/search_settings_page.dart';
import 'package:locus_flutter/features/place_discovery/presentation/pages/card_swipe_page.dart';
import 'package:locus_flutter/features/place_discovery/presentation/pages/list_swipe_page.dart';
import 'package:locus_flutter/features/settings/presentation/pages/settings_page.dart';
import 'package:locus_flutter/features/place_discovery/domain/entities/place_with_distance.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const MainDashboard(),
    ),
    GoRoute(
      path: '/places',
      name: 'places',
      builder: (context, state) => const PlaceListPage(),
    ),
    GoRoute(
      path: '/add-place',
      name: 'add-place',
      builder: (context, state) => const AddPlacePage(),
    ),
    GoRoute(
      path: '/place/:id',
      name: 'place-detail',
      builder: (context, state) {
        final placeId = state.pathParameters['id']!;
        return PlaceDetailPage(placeId: placeId);
      },
    ),
    GoRoute(
      path: '/edit-place/:id',
      name: 'edit-place',
      builder: (context, state) {
        final placeId = state.pathParameters['id']!;
        return EditPlacePage(placeId: placeId);
      },
    ),
    GoRoute(
      path: '/map-picker',
      name: 'map-picker',
      builder: (context, state) => const MapLocationPickerPage(),
    ),
    GoRoute(
      path: '/real-map-picker',
      name: 'real-map-picker',
      builder: (context, state) => const RealMapLocationPickerPage(),
    ),
    GoRoute(
      path: '/discover',
      name: 'discover',
      builder: (context, state) => const PlaceDiscoveryPage(),
    ),
    GoRoute(
      path: '/search-settings',
      name: 'search-settings',
      builder: (context, state) => const SearchSettingsPage(),
    ),
    GoRoute(
      path: '/card-swipe',
      name: 'card-swipe',
      builder: (context, state) {
        final extra = state.extra as List<PlaceWithDistance>;
        return CardSwipePage(places: extra);
      },
    ),
    GoRoute(
      path: '/list-swipe',
      name: 'list-swipe',
      builder: (context, state) {
        final extra = state.extra as List<PlaceWithDistance>;
        return ListSwipePage(places: extra);
      },
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);