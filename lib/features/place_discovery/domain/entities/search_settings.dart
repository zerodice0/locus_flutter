import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_settings.freezed.dart';
part 'search_settings.g.dart';

@freezed
class SearchSettings with _$SearchSettings {
  const factory SearchSettings({
    @Default(2.0) double radiusKm,
    @Default([]) List<String> categoryIds,
    @Default(true) bool considerOperatingHours,
    @Default(true) bool considerEventPeriod,
    @Default(SearchSortOrder.distance) SearchSortOrder sortOrder,
    @Default(false) bool adaptiveRadius,
  }) = _SearchSettings;

  factory SearchSettings.fromJson(Map<String, dynamic> json) =>
      _$SearchSettingsFromJson(json);
}

@JsonEnum()
enum SearchSortOrder {
  @JsonValue('distance')
  distance,
  @JsonValue('name')
  name,
  @JsonValue('category')
  category,
  @JsonValue('created_date')
  createdDate,
}

extension SearchSortOrderExtension on SearchSortOrder {
  String get displayName {
    switch (this) {
      case SearchSortOrder.distance:
        return '거리순';
      case SearchSortOrder.name:
        return '이름순';
      case SearchSortOrder.category:
        return '카테고리순';
      case SearchSortOrder.createdDate:
        return '등록순';
    }
  }
}