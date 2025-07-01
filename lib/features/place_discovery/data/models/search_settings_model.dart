import 'package:locus_flutter/features/place_discovery/domain/entities/search_settings.dart';

class SearchSettingsModel {
  final double radiusKm;
  final List<String> categoryIds;
  final bool considerOperatingHours;
  final bool considerEventPeriod;
  final SearchSortOrder sortOrder;
  final bool adaptiveRadius;

  const SearchSettingsModel({
    required this.radiusKm,
    required this.categoryIds,
    required this.considerOperatingHours,
    required this.considerEventPeriod,
    required this.sortOrder,
    required this.adaptiveRadius,
  });

  factory SearchSettingsModel.fromEntity(SearchSettings entity) {
    return SearchSettingsModel(
      radiusKm: entity.radiusKm,
      categoryIds: entity.categoryIds,
      considerOperatingHours: entity.considerOperatingHours,
      considerEventPeriod: entity.considerEventPeriod,
      sortOrder: entity.sortOrder,
      adaptiveRadius: entity.adaptiveRadius,
    );
  }

  SearchSettings toEntity() {
    return SearchSettings(
      radiusKm: radiusKm,
      categoryIds: categoryIds,
      considerOperatingHours: considerOperatingHours,
      considerEventPeriod: considerEventPeriod,
      sortOrder: sortOrder,
      adaptiveRadius: adaptiveRadius,
    );
  }

  factory SearchSettingsModel.fromJson(Map<String, dynamic> json) {
    return SearchSettingsModel(
      radiusKm: (json['radiusKm'] as num?)?.toDouble() ?? 2.0,
      categoryIds: (json['categoryIds'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      considerOperatingHours: json['considerOperatingHours'] as bool? ?? true,
      considerEventPeriod: json['considerEventPeriod'] as bool? ?? true,
      sortOrder: _parseSearchSortOrder(json['sortOrder'] as String?),
      adaptiveRadius: json['adaptiveRadius'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'radiusKm': radiusKm,
      'categoryIds': categoryIds,
      'considerOperatingHours': considerOperatingHours,
      'considerEventPeriod': considerEventPeriod,
      'sortOrder': sortOrder.name,
      'adaptiveRadius': adaptiveRadius,
    };
  }

  static SearchSortOrder _parseSearchSortOrder(String? value) {
    switch (value) {
      case 'distance':
        return SearchSortOrder.distance;
      case 'name':
        return SearchSortOrder.name;
      case 'category':
        return SearchSortOrder.category;
      case 'createdDate':
        return SearchSortOrder.createdDate;
      default:
        return SearchSortOrder.distance;
    }
  }
}